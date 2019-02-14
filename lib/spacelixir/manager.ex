defmodule Spacelixir.Manager do

  alias Spacelixir.State
  alias Spacelixir.Manager.Time
  alias Spacelixir.Manager.Meteor
  alias Spacelixir.Manager.Shot
  alias Spacelixir.Manager.Spacecraft

  def update(state) do
    state
    |> Time.update()
    |> Meteor.add()
    |> Shot.update()
    |> Meteor.destroy()
    |> Meteor.update()
    |> verify_if_is_game_over()
  end

  defp verify_if_is_game_over(state) do
    if Spacecraft.was_hit?(state) || Meteor.any_destroyed_planet?(state.meteors), do: State.initial_state(), else: state
  end

end
