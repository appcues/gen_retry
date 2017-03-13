defmodule GenRetry.Task do
  @moduledoc ~S"""
  Provides `async/2`, which operates like `Task.async/1` with retry
  capability.
  """

  @doc ~S"""
  Works like `Task.async`, but with retry.  Returns a regular `%Task{}` usable
  with the rest of the functions in `Task`.

  `opts` are GenRetry options.
  The `:respond_to` option is tolerated, but ignored.
  """
  @spec async(GenRetry.retryable_fun, GenRetry.options) :: %Task{}
  def async(fun, opts \\ []) do
    Task.async(task_function(fun, opts))
  end

  defmodule Supervisor do
    @moduledoc ~S"""
    Provides `async/3`, which operates like `Task.Supervisor.async/2`
    with retry capability.
    """

    @doc ~S"""
    Works like `Task.Supervisor.async/2`, but with retry.  Returns a regular
    `%Task{}` usable with the rest of the functions in `Task`.

    `opts` are GenRetry options.
    The `:respond_to` option is tolerated, but ignored.
    """
    @spec async(pid, GenRetry.retryable_fun, GenRetry.options) :: %Task{}
    def async(pid, fun, opts \\ []) do
      Task.Supervisor.async(pid, GenRetry.Task.task_function(fun, opts))
    end

    @doc ~S"""
    Works like `Task.Supervisor.async_nolink/2`, but with retry.  Returns a regular
    `%Task{}` usable with the rest of the functions in `Task`.

    `opts` are GenRetry options.
    The `:respond_to` option is tolerated, but ignored.
    """
    @spec async_nolink(pid, GenRetry.retryable_fun, GenRetry.options) :: %Task{}
    def async_nolink(pid, fun, opts \\ []) do
      Task.Supervisor.async_nolink(pid, GenRetry.Task.task_function(fun, opts))
    end
  end


  @doc false
  @spec task_function(GenRetry.retryable_fun, GenRetry.options) :: fun
  def task_function(fun, opts) do
    fn ->
      GenRetry.retry_link(fun, Keyword.put(opts, :respond_to, self()))
      receive do
        {:success, return_value, _worker_state} -> return_value
        {:failure, error, trace, _worker_state} -> reraise(error, trace)
      end
    end
  end

end
