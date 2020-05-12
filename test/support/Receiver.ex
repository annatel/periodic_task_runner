defmodule PeriodicTaskRunnerTest.Receiver do
  use GenServer

  def start_link(_args \\ []) do
    GenServer.start_link(__MODULE__, %{stack: []}, name: __MODULE__)
  end

  def push(data) when is_binary(data) do
    GenServer.call(__MODULE__, {:push, data})
  end

  def pop() do
    GenServer.call(__MODULE__, :pop)
  end

  def stop() do
    GenServer.stop(__MODULE__)
  end

  def init(state) do
    {:ok, state}
  end

  def handle_call({:push, data}, _from, %{stack: stack} = _state) do
    {:reply, :ok, %{stack: [data | stack]}}
  end

  def handle_call(:pop, _from, %{stack: stack} = _state) do
    {value, stack} = List.pop_at(stack, 0)

    {:reply, value, %{stack: stack}}
  end
end
