defmodule Spacelixir do
  def run do
    ExNcurses.initscr()

    ExNcurses.listen()
    ExNcurses.noecho()
    ExNcurses.keypad()
    ExNcurses.curs_set(0)

    state = stateInit()

    schedule_next_tick()
    loop(state)
  end

  def stateInit do
    %{spacecraft: %{x: 20, y: 30}, shots: [], meteors: [], time: 0, score: 0}
  end

  def loop(state) do
    receive do
      {:ex_ncurses, :key, key} ->
        loop(handle_key(key, state))

      :tick ->
        schedule_next_tick()
        state
        |> draw()
        |> update()
        |> loop()
    end
  end

  def schedule_next_tick do
    Process.send_after(self(), :tick, 33)
  end

  defp handle_key(?w, state), do: update_spacecraft(state, state.spacecraft.x,     state.spacecraft.y - 1)
  defp handle_key(?a, state), do: update_spacecraft(state, state.spacecraft.x - 1, state.spacecraft.y    )
  defp handle_key(?s, state), do: update_spacecraft(state, state.spacecraft.x,     state.spacecraft.y + 1)
  defp handle_key(?d, state), do: update_spacecraft(state, state.spacecraft.x + 1, state.spacecraft.y    )
  defp handle_key(?q, _),     do: ExNcurses.endwin()
  defp handle_key(?k, state) do
    ExNcurses.beep()
    %{state| shots: state.shots ++ [%{x: state.spacecraft.x+1, y: state.spacecraft.y}]}
  end
  defp handle_key(_, state),  do: state

  defp update_spacecraft(state, x, y) do
    if x <= 38 && x >= 0 && y <= 39 && y >= 0 do
      %{state | spacecraft: %{x: x, y: y}}
    else
      state
    end
  end

  defp draw(state) do
    ExNcurses.clear()
    draw_borders()
    draw_shots(state.shots)
    draw_meteors(state.meteors)
    draw_spacecraft(state.spacecraft)
    draw_score(state.score)
    ExNcurses.refresh()
    state
  end

  defp draw_borders() do
    (0..40)
    |> Enum.each(fn limit ->
      ExNcurses.mvaddstr(41, limit, "-")
      ExNcurses.mvaddstr(limit, 41, "|")
    end)
  end

  defp draw_score(score) do
    ExNcurses.mvaddstr(5, 50, "SCORE")
    ExNcurses.mvaddstr(5, 57, to_string(score))
  end

  defp draw_meteors(meteors) do
    Enum.each(meteors, fn meteor ->
      ExNcurses.mvaddstr(0 + meteor.y, 0 + meteor.x, "+")
      ExNcurses.mvaddstr(0 + meteor.y, 1 + meteor.x, "+")
      ExNcurses.mvaddstr(0 + meteor.y, 2 + meteor.x, "+")
      ExNcurses.mvaddstr(1 + meteor.y, 0 + meteor.x, "+")
      ExNcurses.mvaddstr(1 + meteor.y, 1 + meteor.x, "+")
      ExNcurses.mvaddstr(1 + meteor.y, 2 + meteor.x, "+")
    end)
  end

  defp draw_shots(shots) do
    Enum.each(shots, fn shot -> ExNcurses.mvaddstr(shot.y, shot.x, ".") end)
  end

  defp draw_spacecraft(spacecraft) do
    ExNcurses.mvaddstr(0 + spacecraft.y, 0 + spacecraft.x, "-")
    ExNcurses.mvaddstr(0 + spacecraft.y, 1 + spacecraft.x, "|")
    ExNcurses.mvaddstr(0 + spacecraft.y, 2 + spacecraft.x, "-")
    ExNcurses.mvaddstr(1 + spacecraft.y, 0 + spacecraft.x, "-")
    ExNcurses.mvaddstr(1 + spacecraft.y, 1 + spacecraft.x, "-")
    ExNcurses.mvaddstr(1 + spacecraft.y, 2 + spacecraft.x, "-")
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
    if spacecraft_was_hit?(state) || any_meteor_destroyed_planet?(state.meteors), do: stateInit(), else: state
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
