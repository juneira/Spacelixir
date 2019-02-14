defmodule Spacelixir.UI.Spacecraft do

  def draw(spacecraft) do
    ExNcurses.mvaddstr(0 + spacecraft.y, 0 + spacecraft.x, "-")
    ExNcurses.mvaddstr(0 + spacecraft.y, 1 + spacecraft.x, "|")
    ExNcurses.mvaddstr(0 + spacecraft.y, 2 + spacecraft.x, "-")
    ExNcurses.mvaddstr(1 + spacecraft.y, 0 + spacecraft.x, "-")
    ExNcurses.mvaddstr(1 + spacecraft.y, 1 + spacecraft.x, "-")
    ExNcurses.mvaddstr(1 + spacecraft.y, 2 + spacecraft.x, "-")
  end

end
