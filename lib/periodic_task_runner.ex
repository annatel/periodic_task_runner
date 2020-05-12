defmodule PeriodicTaskRunner do
  @moduledoc """
  Documentation for PeriodicTaskRunner.
  """

  @spec start_task(binary(), (() -> any), integer) ::
          :ignore | {:error, any} | {:ok, pid} | {:ok, pid, any}
  def start_task(name, fun, period)
      when is_binary(name) and is_function(fun, 0) and is_integer(period) do
    if task_exists?(name) do
      {:error, :already_exist}
    else
      DynamicSupervisor.start_child(
        PeriodicTaskRunner.DynamicSupervisor,
        {PeriodicTaskRunner.Worker,
         [fun: fun, period: period, name: {:via, Registry, {PeriodicTaskRunner.Registry, name}}]}
      )
    end
  end

  @spec stop_task(binary()) :: :ok | {:error, :not_found}
  def stop_task(name) when is_binary(name) do
    pid = get_task_pid(name)

    if is_nil(pid) do
      {:error, :not_found}
    else
      DynamicSupervisor.terminate_child(PeriodicTaskRunner.DynamicSupervisor, pid)
    end
  end

  @spec task_exists?(binary()) :: boolean
  def task_exists?(name) when is_binary(name) do
    not is_nil(get_task_pid(name))
  end

  defp get_task_pid(name) do
    case Registry.lookup(PeriodicTaskRunner.Registry, name) do
      [{pid, _}] ->
        pid

      [] ->
        nil
    end
  end
end
