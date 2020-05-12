defmodule PeriodicTaskRunner.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {Registry, keys: :unique, name: PeriodicTaskRunner.Registry},
      {DynamicSupervisor, strategy: :one_for_one, name: PeriodicTaskRunner.DynamicSupervisor}
    ]

    opts = [strategy: :one_for_one, name: PeriodicTaskRunner.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
