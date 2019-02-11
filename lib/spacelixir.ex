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
    %{spacecraft: %{x: 50, y: 50}, shots: [], meteors: [], time: 0}
  end

  def loop(state) do
    receive do
      {:ex_ncurses, :key, key} ->
        loop(handle_key(key, state))

      :tick ->
        schedule_next_tick()
        draw(state)
        state
        |> update()
        |> loop()
    end
  end

  def schedule_next_tick do
    Process.send_after(self(), :tick, 100)
  end

  defp handle_key(?w, state), do: %{state | spacecraft: %{x: state.spacecraft.x,     y: state.spacecraft.y - 1 }}
  defp handle_key(?a, state), do: %{state | spacecraft: %{x: state.spacecraft.x - 1, y: state.spacecraft.y     }}
  defp handle_key(?s, state), do: %{state | spacecraft: %{x: state.spacecraft.x,     y: state.spacecraft.y + 1 }}
  defp handle_key(?d, state), do: %{state | spacecraft: %{x: state.spacecraft.x + 1, y: state.spacecraft.y     }}
  defp handle_key(?q, _),     do: ExNcurses.endwin()

  defp handle_key(?k, state) do
    ExNcurses.beep()
    %{state| shots: state.shots ++ [%{x: state.spacecraft.x+1, y: state.spacecraft.y}]}
  end

  defp draw(state) do
    ExNcurses.clear()
    draw_shots(state.shots)
    draw_meteors(state.meteors)
    draw_spacecraft(state.spacecraft)
    ExNcurses.refresh()
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
    |> update_meteors()
  end

  def update_time(state) do
    %{state | time: state.time + 1}
  end

  defp update_meteors(state) do
    %{state | meteors: generate_meteors_arr(state.meteors)}
  end

  def add_meteor(state) do
    if rem(state.time, 10) == 0 do
      %{state | meteors: state.meteors ++ [%{x: :rand.uniform(40), y: 1}]}
    else
      state
    end
  end

  defp update_shots(state) do
    %{state | shots: generate_shots_arr(state.shots)}
  end

  defp generate_shots_arr(shots) do
    shots
    |> Enum.map(fn shot -> %{x: shot.x, y: shot.y - 1} end)
    |> Enum.filter(fn shot -> shot.x >= 0 && shot.y >= 0 end)
  end

  defp generate_meteors_arr(meteors) do
    meteors
    |> Enum.map(fn meteor -> %{x: meteor.x, y: meteor.y + 1} end)
    |> Enum.filter(fn meteor -> meteor.y < 50 end)
  end
end
