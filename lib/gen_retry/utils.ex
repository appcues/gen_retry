defmodule GenRetry.Utils do
  require Logger

  @behaviour GenRetry.Logger

  @impl true
  def log(message) do
    Logger.error(message)
  end
end
