defmodule GenRetry.Logger do
  @callback log(String.t()) :: String.t()
end
