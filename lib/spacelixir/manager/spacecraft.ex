defmodule Spacelixir.Manager.Spacecraft do

  def was_hit?(state) do
    state.meteors
    |> Enum.any?(fn meteor -> was_destroyed?(meteor, state.spacecraft) end)
  end

  defp was_destroyed?(meteor, spacecraft) do
    (meteor.x <= spacecraft.x && spacecraft.x <= meteor.x+2) && (meteor.y <= spacecraft.y && spacecraft.y <= meteor.y+1) ||
      (meteor.x <= spacecraft.x+2 && spacecraft.x+2 <= meteor.x+2) && (meteor.y <= spacecraft.y && spacecraft.y <= meteor.y+1) ||
      (meteor.x <= spacecraft.x && spacecraft.x <= meteor.x+2) && (meteor.y <= spacecraft.y+1 && spacecraft.y+1 <= meteor.y+1) ||
      (meteor.x <= spacecraft.x+2 && spacecraft.x <= meteor.x+2) && (meteor.y <= spacecraft.y+1 && spacecraft.y+1 <= meteor.y+1)
  end

end
