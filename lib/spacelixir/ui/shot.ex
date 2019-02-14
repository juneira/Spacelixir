defmodule Spacelixir.UI.Shot do

  def draw(shots) do
    Enum.each(shots, fn shot -> ExNcurses.mvaddstr(shot.y, shot.x, ".") end)
  end

end
