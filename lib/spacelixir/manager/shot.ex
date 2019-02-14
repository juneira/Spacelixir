defmodule Spacelixir.Manager.Shot do

  alias Spacelixir.Manager.Meteor

  def update(state) do
    %{state | shots: generate_new_positions(state.shots)}
  end

  def valids(state) do
    state.shots
    |> Enum.filter(fn shot ->
      not Enum.any?(state.meteors, fn meteor ->
        Meteor.was_destroyed?(meteor, shot)
      end)
    end)
  end

  defp generate_new_positions(shots) do
    shots
    |> Enum.map(fn shot -> %{x: shot.x, y: shot.y - 1} end)
    |> Enum.filter(fn shot -> shot.x >= 0 && shot.y >= 0 end)
  end

end
