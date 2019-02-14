defmodule Spacelixir.Manager.Meteor do

  alias Spacelixir.Manager.Shot
  alias Spacelixir.Manager.Score

  def update(state) do
    if rem(state.time, 5) == 0 do
      %{state | meteors: generate_new_positions(state.meteors)}
    else
      state
    end
  end

  def add(state) do
    if rem(state.time, 20) == 0 do
      %{state | meteors: state.meteors ++ [%{x: :rand.uniform(37), y: 1}]}
    else
      state
    end
  end

  def destroy(state) do
    %{state | meteors: valids(state), shots: Shot.valids(state), score: Score.update(state)}
  end

  def valids(state) do
    state.meteors
    |> Enum.filter(fn meteor ->
      not Enum.any?(state.shots, fn shot ->
        was_destroyed?(meteor, shot)
      end)
    end)
  end

  def any_was_destroyed?(state) do
    state.meteors
    |> Enum.any?(fn meteor ->
      Enum.any?(state.shots, fn shot ->
        was_destroyed?(meteor, shot)
      end)
    end)
  end

  def any_destroyed_planet?(meteors) do
    meteors
    |> Enum.any?(fn meteor -> meteor.y >= 38 end)
  end

  def was_destroyed?(meteor, shot) do
    (meteor.x <= shot.x && shot.x <= meteor.x+2) && (meteor.y <= shot.y && shot.y <= meteor.y+1)
  end

  defp generate_new_positions(meteors) do
    meteors
    |> Enum.map(fn meteor -> %{x: meteor.x, y: meteor.y + 1} end)
  end

end
