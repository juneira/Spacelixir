defmodule Spacelixir do

  alias Spacelixir.UI
  alias Spacelixir.IO.Keyboard
  alias Spacelixir.State

  def run do
    UI.initialize()
    Keyboard.start_listen()
    schedule_next_tick()
    State.initial_state()
    |> loop()
  end

  def loop(state) do
    receive do
      {:ex_ncurses, :key, key} ->
        loop(Keyboard.handle_key(key, state))

      :tick ->
        schedule_next_tick()
        state
        |> UI.draw()
        |> update()
        |> loop()
    end
  end

  def schedule_next_tick do
    Process.send_after(self(), :tick, 33)
  end

  defp update_spacecraft(state, x, y) do
    if x <= 38 && x >= 0 && y <= 39 && y >= 0 do
      %{state | spacecraft: %{x: x, y: y}}
    else
      state
    end
  end

  defp update(state) do
    state
    |> update_time()
    |> add_meteor()
    |> update_shots()
    |> destroy_meteors()
    |> update_meteors()
    |> verify_if_is_game_over()
  end

  defp update_spacecraft(state, x, y) do
    if x <= 38 && x >= 0 && y <= 39 && y >= 0 do
      %{state | spacecraft: %{x: x, y: y}}
    else
      state
    end
  end

  def update_time(state) do
    %{state | time: state.time + 1}
  end

  defp update_meteors(state) do
    if rem(state.time, 5) == 0 do
      %{state | meteors: generate_meteors_list(state.meteors)}
    else
      state
    end
  end

  defp destroy_meteors(state) do
    %{state | meteors: valid_meteors_list(state), shots: valid_shots_list(state), score: update_score(state)}
  end

  defp update_score(state) do
    if had_destroyed_meteor?(state), do: state.score + 1, else: state.score
  end

  defp had_destroyed_meteor?(state) do
    state.meteors
    |> Enum.any?(fn meteor ->
      Enum.any?(state.shots, fn shot ->
        meteor_was_destroyed?(meteor, shot)
      end)
    end)
  end

  defp verify_if_is_game_over(state) do
    if spacecraft_was_hit?(state) || any_meteor_destroyed_planet?(state.meteors), do: State.initial_state(), else: state
  end

  def spacecraft_was_hit?(state) do
    state.meteors
    |> Enum.any?(fn meteor -> spacecraft_was_destroyed?(meteor, state.spacecraft) end)
  end

  defp valid_meteors_list(state) do
    state.meteors
    |> Enum.filter(fn meteor ->
      not Enum.any?(state.shots, fn shot ->
        meteor_was_destroyed?(meteor, shot)
      end)
    end)
  end

  defp valid_shots_list(state) do
    state.shots
    |> Enum.filter(fn shot ->
      not Enum.any?(state.meteors, fn meteor ->
        meteor_was_destroyed?(meteor, shot)
      end)
    end)
  end

  defp meteor_was_destroyed?(meteor, shot) do
    (meteor.x <= shot.x && shot.x <= meteor.x+2) && (meteor.y <= shot.y && shot.y <= meteor.y+1)
  end

  defp spacecraft_was_destroyed?(meteor, spacecraft) do
    (meteor.x <= spacecraft.x && spacecraft.x <= meteor.x+2) && (meteor.y <= spacecraft.y && spacecraft.y <= meteor.y+1) ||
      (meteor.x <= spacecraft.x+2 && spacecraft.x+2 <= meteor.x+2) && (meteor.y <= spacecraft.y && spacecraft.y <= meteor.y+1) ||
      (meteor.x <= spacecraft.x && spacecraft.x <= meteor.x+2) && (meteor.y <= spacecraft.y+1 && spacecraft.y+1 <= meteor.y+1) ||
      (meteor.x <= spacecraft.x+2 && spacecraft.x <= meteor.x+2) && (meteor.y <= spacecraft.y+1 && spacecraft.y+1 <= meteor.y+1)
  end

  defp any_meteor_destroyed_planet?(meteors) do
    meteors
    |> Enum.any?(fn meteor -> meteor.y >= 38 end)
  end

  defp add_meteor(state) do
    if rem(state.time, 20) == 0 do
      %{state | meteors: state.meteors ++ [%{x: :rand.uniform(37), y: 1}]}
    else
      state
    end
  end

  defp update_shots(state) do
    %{state | shots: generate_shots_list(state.shots)}
  end

  defp generate_shots_list(shots) do
    shots
    |> Enum.map(fn shot -> %{x: shot.x, y: shot.y - 1} end)
    |> Enum.filter(fn shot -> shot.x >= 0 && shot.y >= 0 end)
  end

  defp generate_meteors_list(meteors) do
    meteors
    |> Enum.map(fn meteor -> %{x: meteor.x, y: meteor.y + 1} end)
  end
end
