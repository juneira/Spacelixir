defmodule Spacelixir.UI do

  alias Spacelixir.UI.Meteor
  alias Spacelixir.UI.Screen
  alias Spacelixir.UI.Shot
  alias Spacelixir.UI.Spacecraft

  def initialize do
    ExNcurses.initscr()
  end

  def draw(state) do
    ExNcurses.clear()
    Screen.draw_borders()
    Shot.draw(state.shots)
    Meteor.draw(state.meteors)
    Spacecraft.draw(state.spacecraft)
    Screen.draw_score(state.score)
    ExNcurses.refresh()
    state
  end

end
