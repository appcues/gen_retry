defmodule GenRetry.TestLogger do
  @behaviour GenRetry.Logger

  @impl true
  def log(_message) do
    "do nothing"
  end
end
