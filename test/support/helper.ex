defmodule PeriodicTaskRunnerTest.Helper do
  def tear_down(name) do
    case Registry.lookup(PeriodicTaskRunner.Registry, name) do
      [{pid, _}] ->
        DynamicSupervisor.terminate_child(PeriodicTaskRunner.DynamicSupervisor, pid)

      [] ->
        :noop
    end

    Registry.unregister(PeriodicTaskRunner.Registry, name)
  end
end
