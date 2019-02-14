defmodule Spacelixir.Manager.Time do

  def update(state) do
    %{state | time: state.time + 1}
  end

end
