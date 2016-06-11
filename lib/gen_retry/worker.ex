defmodule GenRetry.Worker do
  @moduledoc false

  use GenServer

  defmodule State do
    @moduledoc false
    defstruct function: nil,  # the function to retry
              opts: nil,      # %GenRetry.Options{} from caller
              tries: 0,       # number of tries performed so far
              retry_at: 0     # :erlang.system_time(:milli_seconds)
  end


  @spec init({fun, GenRetry.Options.t}) :: {:ok, %State{}}
  def init({fun, opts}) do
    GenServer.cast(self, :try)
    {:ok, %State{function: fun, opts: opts}}
  end

  @spec handle_cast(:try, %State{}) :: {:noreply, %State{}} | {:stop, :normal, %State{}}
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
          GenServer.cast(self, :try)
          {:noreply, %{state | retry_at: retry_at}}
        else
          if pid = state.opts.respond_to do
            send(pid, {:failure, e, trace, state})
          end
          {:stop, :normal, state}
        end
    end
  end


  @spec delay_time(%State{}) :: integer
  defp delay_time(state) do
    base_delay = state.opts.delay * :math.pow(state.opts.exp_base, state.tries)
    jitter = :random.uniform * base_delay * state.opts.jitter
    round(base_delay + jitter)
  end

  @spec should_try_again(%State{}) :: boolean
  defp should_try_again(state) do
    (state.opts.retries == :infinity) || (state.opts.retries >= state.tries)
  end
end

