defmodule GenRetry.Worker do
  @moduledoc false

  alias GenRetry.State

  use GenServer

  @spec init({GenRetry.retryable_fun, GenRetry.Options.t}) :: {:ok, GenRetry.State.t}
  def init({fun, opts}) do
    GenServer.cast(self(), :try)
    {:ok, %State{function: fun, opts: opts}}
  end

  @spec handle_cast(:try, GenRetry.State.t) :: {:noreply, GenRetry.State.t} | {:stop, :normal, GenRetry.State.t}
  def handle_cast(:try, state) do
    sleep_for = round(state.retry_at - :erlang.system_time(:milli_seconds))
    if sleep_for > 0, do: :timer.sleep(sleep_for)

    state = %{state | tries: state.tries + 1}
    try do
      return_value = state.function.()
      if pid = state.opts.respond_to do
        send(pid, {:success, return_value, state})
      end
      {:stop, :normal, state}
    rescue
      e ->
        trace = System.stacktrace
        if should_try_again(state) do
          retry_at = :erlang.system_time(:milli_seconds) + delay_time(state)
          GenServer.cast(self(), :try)
          {:noreply, %{state | retry_at: retry_at}}
        else
          if pid = state.opts.respond_to do
            send(pid, {:failure, e, trace, state})
          end
          {:stop, :normal, state}
        end
    end
  end


  @spec delay_time(GenRetry.State.t) :: integer
  defp delay_time(state) do
    base_delay = state.opts.delay * :math.pow(state.opts.exp_base, state.tries)
    jitter = :rand.uniform * base_delay * state.opts.jitter
    round(base_delay + jitter)
  end

  @spec should_try_again(GenRetry.State.t) :: boolean
  defp should_try_again(state) do
    (state.opts.retries == :infinity) || (state.opts.retries >= state.tries)
  end
end
