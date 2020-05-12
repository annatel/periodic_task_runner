defmodule PeriodicTaskRunner.Worker do
  @moduledoc false

  use GenServer

  # Callbacks

  def start_link(fun: fun, period: period, name: name) do
    GenServer.start_link(__MODULE__, %{fun: fun, period: period}, name: name)
  end

  # Server Callbacks

  @impl true
  def init(%{period: period} = state) do
    schedule_work(period)

    {:ok, state}
  end

  @impl true
  def handle_info(:work, %{fun: fun, period: period} = state) do
    exec_fun(fun)

    schedule_work(period)

    {:noreply, state}
  end

  defp schedule_work(period) do
    Process.send_after(self(), :work, period)
  end

  defp exec_fun(fun) do
    fun.()
  end
end
