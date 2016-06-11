defmodule GenRetry.Launcher do
  @moduledoc false

  use GenServer

  @type launch :: {:launch, fun, GenRetry.options}
  @type state :: %GenRetry.Launcher.State{}

  defmodule State do
    @moduledoc false
    defstruct launches: 0
  end

  @spec launch(fun, GenRetry.options) :: pid
  def launch(fun, opts) do
    GenServer.call(:gen_retry_launcher, {:launch, fun, opts})
  end

  def start_link(state, opts \\ []) do
    GenServer.start_link(__MODULE__, state, opts)
  end

  @spec init(any) :: {:ok, state}
  def init(_) do
    {:ok, %State{}}
  end

  @spec handle_call(launch, any, state) :: {:reply, pid, state}
  def handle_call({:launch, fun, opts}, _from, state) do
    pid = GenRetry.retry_link(fun, opts)
    {:reply, pid, %{state | launches: state.launches+1}}
  end
end

