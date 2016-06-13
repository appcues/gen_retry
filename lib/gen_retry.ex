defmodule GenRetry do
  @moduledoc ~S"""
  GenRetry provides utilities for retrying Elixir functions,
  with configurable delay and backoff characteristics.

  Given a function which raises an exception upon failure, `retry/2`
  and `retry_link/2` repeatedly executes the function until success is
  reached or the maximum number of retries has occurred.

  `GenRetry.Task.async/2` and `GenRetry.Task.Supervisor.async/3`
  provide drop-in replacements for `Task.async/1` and
  `Task.Supervisor.async/2`, respectively, adding retry capability.
  They return plain `%Task{}` structs, usable with any other function in
  the `Task` module.

  ## Options

  * `:retries`, integer (default 1):
    Number of times to retry upon failure.  Set to
    0 to try exactly once; set to `:infinity` to retry forever.

  * `:delay`, integer (default 1000):
    Number of milliseconds to wait between first failure and first retry.
    Subsequent retries use this value as a starting point for exponential
    backoff.

  * `:jitter`, number (0.0 to 1.0, default 0):
    Proportion of current retry delay to randomly add to delay time.
    For example, given options `delay: 1000, jitter: 0.1`, the first delay
    will be a random time between 1000 and 1100 milliseconds.

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
      worker(GenRetry.Launcher, [[], [name: :gen_retry_launcher]])
    ]
    opts = [strategy: :one_for_one, name: GenRetry.Supervisor]
    Supervisor.start_link(children, opts)
  end


  defmodule Options do
    @moduledoc false
    @type t :: %__MODULE__{}
    defstruct retries: 1,
              delay: 1000,
              jitter: 0,
              exp_base: 2,
              respond_to: nil
    use ExConstructor
  end

  @type option ::
          {:retries, :infinity | non_neg_integer} |
          {:delay, non_neg_integer} |
          {:jitter, number} |
          {:exp_base, number} |
          {:respond_to, pid}

  @type options :: [option]


  @doc ~S"""
  Starts a retryable process linked to `GenRetry.Supervisor`, and returns its
  pid.  `func` should be a function that raises an exception upon failure;
  any other return value is treated as success.
  """
  @spec retry(fun, options) :: pid
  def retry(fun, opts \\ []) do
    GenRetry.Launcher.launch(fun, opts)
  end


  @doc ~S"""
  Starts a retryable process linked to the current process, and returns its
  pid.  `func` should be a function that raises an exception upon failure;
  any other return value is treated as success.
  """
  @spec retry_link(fun, options) :: pid
  def retry_link(fun, opts \\ []) do
    {:ok, pid} = GenServer.start_link(GenRetry.Worker, {fun, Options.new(opts)}, timeout: :infinity)
    pid
  end

end

