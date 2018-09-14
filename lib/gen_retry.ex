defmodule GenRetry do
  @moduledoc ~s"""
  GenRetry provides utilities for retrying Elixir functions,
  with configurable delay and backoff characteristics.

  ## Summary

  Given a 0-arity function which raises an exception upon failure, `retry/2`
  and `retry_link/2` repeatedly executes the function until success is
  reached or the maximum number of retries has occurred.

  `GenRetry.Task.async/2` and `GenRetry.Task.Supervisor.async/3`
  provide drop-in replacements for `Task.async/1` and
  `Task.Supervisor.async/2`, respectively, adding retry capability.
  They return plain `%Task{}` structs, usable with any other function in
  the `Task` module.


  ## Examples

      my_background_function = fn ->
        :ok = try_to_send_tps_reports()
      end
      GenRetry.retry(my_background_function, retries: 10, delay: 10_000)

      my_future_function = fn ->
        {:ok, val} = get_val_from_flaky_network_service()
        val
      end
      t = GenRetry.Task.async(my_future_function, retries: 3)
      my_val = Task.await(t)  # may raise exception


  ## Installation

  1. Add GenRetry to your list of dependencies in `mix.exs`:

          def deps do
            [{:gen_retry, "~> #{GenRetry.Mixfile.project()[:version]}"}]
          end

  2. Ensure GenRetry is started before your application:

          def application do
            [applications: [:gen_retry]]
          end


  ## Options

  * `:retries`, integer (default 1):
    Number of times to retry upon failure.  Set to
    0 to try exactly once; set to `:infinity` to retry forever.

  * `:delay`, integer (default 1000):
    Number of milliseconds to wait between first failure and first retry.
    Subsequent retries use this value as a starting point for exponential
    backoff.

  * `:jitter`, number (default 0):
    Proportion of current retry delay to randomly add to delay time.
    For example, given options `delay: 1000, jitter: 0.1`, the first delay
    will be a random time between 1000 and 1100 milliseconds.  Values
    under 0 will remove time rather than add it; beware of values under -1,
    which may result in nonsensical "negative time delays".

  * `:exp_base`, number (default 2):
    The base to use for exponentiation during exponential backoff.
    Set to `1` to disable backoff.  Values less than 1 are not very useful.

  * `:respond_to`, pid (ignored by `GenRetry.Task.*`):
    The process ID to which a message should be sent upon completion.
    Successful exits send `{:success, return_value, final_retry_state}`;
    unsuccessful exits send `{:failure, error, stacktrace, final_retry_state}`.
  """

  use Application

  @doc false
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(GenRetry.Launcher, [[], [name: :gen_retry_launcher]]),
    ]

    opts = [strategy: :one_for_one, name: GenRetry.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defmodule State do
    @moduledoc ~S"""
    Used to represent the state of a GenRetry invocation.
    This struct is part of the success or failure message to be
    optionally sent to another process, specified by `opts[:respond_to]`,
    upon completion.

    * `:function` and `:opts` are the invocation arguments supplied by the user.
    * `:tries` is the total number of attempts made before sending this message.
    * `:retry_at` is either the timestamp of the last attempt, or 0
      (if `opts[:retries] == 0`).
    """

    # the function to retry
    defstruct function: nil,
              # %GenRetry.Options{} from caller
              opts: nil,
              # number of tries performed so far
              tries: 0,
              # :erlang.system_time(:milli_seconds)
              retry_at: 0

    @type t :: %__MODULE__{
            function: GenRetry.retryable_fun(),
            opts: GenRetry.Options.t(),
            tries: non_neg_integer,
            retry_at: non_neg_integer,
          }
  end

  defmodule Options do
    @moduledoc false
    defstruct retries: 1,
              delay: 1000,
              jitter: 0,
              exp_base: 2,
              respond_to: nil

    @type t :: %__MODULE__{
            retries: :infinity | non_neg_integer,
            delay: non_neg_integer,
            jitter: number,
            exp_base: number,
            respond_to: pid | nil,
          }

    use ExConstructor
  end

  @type option ::
          {:retries, :infinity | non_neg_integer}
          | {:delay, non_neg_integer}
          | {:jitter, number}
          | {:exp_base, number}
          | {:respond_to, pid}

  @type options :: [option]

  @type retryable_fun :: (() -> any | no_return)

  @type success_msg :: {:success, any, GenRetry.State.t()}

  @type failure_msg ::
          {:failure, Exception.t(), [:erlang.stack_item()], GenRetry.State.t()}

  @doc ~S"""
  Starts a retryable process linked to `GenRetry.Supervisor`, and returns its
  pid.  `fun` should be a function that raises an exception upon failure;
  any other return value is treated as success.
  """
  @spec retry(retryable_fun, options) :: pid
  def retry(fun, opts \\ []) do
    GenRetry.Launcher.launch(fun, opts)
  end

  @doc ~S"""
  Starts a retryable process linked to the current process, and returns its
  pid.  `fun` should be a function that raises an exception upon failure;
  any other return value is treated as success.
  """
  @spec retry_link(retryable_fun, options) :: pid
  def retry_link(fun, opts \\ []) do
    {:ok, pid} =
      GenServer.start_link(
        GenRetry.Worker,
        {fun, Options.new(opts)},
        timeout: :infinity
      )

    pid
  end
end
