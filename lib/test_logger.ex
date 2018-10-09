defmodule GenRetry.TestLogger do
  @behaviour GenRetry.Logger

  def log(_message) do
    "do nothing"
  end
end
