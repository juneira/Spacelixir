defmodule Spacelixir.UI.Meteor do

  def draw(meteors) do
    Enum.each(meteors, fn meteor ->
      ExNcurses.mvaddstr(0 + meteor.y, 0 + meteor.x, "+")
      ExNcurses.mvaddstr(0 + meteor.y, 1 + meteor.x, "+")
      ExNcurses.mvaddstr(0 + meteor.y, 2 + meteor.x, "+")
      ExNcurses.mvaddstr(1 + meteor.y, 0 + meteor.x, "+")
      ExNcurses.mvaddstr(1 + meteor.y, 1 + meteor.x, "+")
      ExNcurses.mvaddstr(1 + meteor.y, 2 + meteor.x, "+")
    end)
  end

end
