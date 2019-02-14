defmodule Spacelixir.UI.Screen do

  def draw_borders() do
    (0..40)
    |> Enum.each(fn limit ->
      ExNcurses.mvaddstr(41, limit, "-")
      ExNcurses.mvaddstr(limit, 41, "|")
    end)
  end

  def draw_score(score) do
    ExNcurses.mvaddstr(5, 50, "SCORE")
    ExNcurses.mvaddstr(5, 57, to_string(score))
  end

end
