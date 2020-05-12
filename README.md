# PeriodicTaskRunner

A periodically task runner. The runner wait to the former task to end before it runs the new one.

## Installation

```elixir
def deps do
  [
    {:periodic_task_runner, git: "git@github.com:periodic_task_runner.git", tag: "0.1.0"}
  ]
end
```

## How to use

```elixir
iex> task = fn -> IO.inspect("YouCanDoIt") end
iex> one_minute_in_ms = 60_000
iex> {:ok, _pid} = PeriodicTaskRunner.start_task("self_motivation", task, one_minute_in_ms)
# After one minute
iex> "YouCanDoIt"
# After one minute
iex> "YouCanDoIt"
# After one minute
iex> "YouCanDoIt"
# After one minute
iex> "YouCanDoIt"
# After one minute
iex> "YouCanDoIt"
iex> true = PeriodicTaskRunner.task_exists?("self_motivation")
iex> :ok = PeriodicTaskRunner.stop_task("self_motivation")
```