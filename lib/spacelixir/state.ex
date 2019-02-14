defmodule Spacelixir.State do

  def initial_state do
    %{spacecraft: %{x: 20, y: 30}, shots: [], meteors: [], time: 0, score: 0}
  end

end
