defmodule Spacelixir.Manager.Score do

  alias Spacelixir.Manager.Meteor

  def update(state) do
    if Meteor.any_was_destroyed?(state), do: state.score + 1, else: state.score
  end

end
