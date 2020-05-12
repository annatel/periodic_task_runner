defmodule PeriodicTaskRunnerTest do
  use ExUnit.Case

  describe "start_task_runner/3" do
    test "start a task with a function that takes a parameter" do
      fun = fn _ -> :noop end

      assert_raise FunctionClauseError, fn ->
        PeriodicTaskRunner.start_task("name", fun, 60_000) == {:error, :already_exist}
      end
    end

    test "start a task that already exist" do
      task_name = "task_name"
      on_exit(fn -> PeriodicTaskRunnerTest.Helper.tear_down(task_name) end)
      PeriodicTaskRunnerTest.Helper.tear_down(task_name)

      fun = fn -> :noop end
      PeriodicTaskRunner.start_task(task_name, fun, 60_000)
      assert PeriodicTaskRunner.start_task(task_name, fun, 60_000) == {:error, :already_exist}
    end

    test "start a task that doesn't exist" do
      task_name = "task_name"
      on_exit(fn -> PeriodicTaskRunnerTest.Helper.tear_down(task_name) end)
      PeriodicTaskRunnerTest.Helper.tear_down(task_name)

      {:ok, _pid} = PeriodicTaskRunnerTest.Receiver.start_link()

      fun = fn -> PeriodicTaskRunnerTest.Receiver.push("hello") end
      assert {:ok, _} = PeriodicTaskRunner.start_task(task_name, fun, 500)

      :timer.sleep(600)

      assert "hello" = PeriodicTaskRunnerTest.Receiver.pop()
      assert is_nil(PeriodicTaskRunnerTest.Receiver.pop())

      :timer.sleep(600)

      assert "hello" = PeriodicTaskRunnerTest.Receiver.pop()

      PeriodicTaskRunnerTest.Receiver.stop()
    end
  end

  describe "task_exists?/1" do
    test "task does not exist" do
      refute PeriodicTaskRunner.task_exists?("task_name")
    end

    test "task exists" do
      task_name = "task_name"
      on_exit(fn -> PeriodicTaskRunnerTest.Helper.tear_down(task_name) end)

      PeriodicTaskRunnerTest.Helper.tear_down(task_name)

      fun = fn -> :noop end
      PeriodicTaskRunner.start_task(task_name, fun, 60_000)

      assert PeriodicTaskRunner.task_exists?(task_name)
    end
  end

  describe "stop_task" do
    test "task that does not exists" do
      assert {:error, :not_found} = PeriodicTaskRunner.stop_task("non_existing_task")
    end

    test "task is already stopped" do
      task_name = "task_name"
      on_exit(fn -> PeriodicTaskRunnerTest.Helper.tear_down(task_name) end)

      PeriodicTaskRunnerTest.Helper.tear_down(task_name)

      task = fn -> :noop end
      PeriodicTaskRunner.start_task(task_name, task, 60_000)

      PeriodicTaskRunner.stop_task(task_name)
      assert {:error, :not_found} = PeriodicTaskRunner.stop_task(task_name)
    end

    test "when task is running" do
      task_name = "task_name"
      on_exit(fn -> PeriodicTaskRunnerTest.Helper.tear_down(task_name) end)

      PeriodicTaskRunnerTest.Helper.tear_down(task_name)

      task = fn -> :noop end
      PeriodicTaskRunner.start_task(task_name, task, 60_000)

      assert :ok = PeriodicTaskRunner.stop_task(task_name)
    end
  end
end
