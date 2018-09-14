defmodule GenRetry.Utils do
  require Logger

  @behaviour GenRetry.Logger

  def log(message) do
    Logger.error(message)
  end
end
