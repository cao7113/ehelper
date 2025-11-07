defmodule TaskTest do
  use ExUnit.Case

  @moduletag :manual

  test "async and await" do
    t =
      Task.async(fn ->
        Process.sleep(500)
        2
      end)

    assert 1 + Task.await(t) == 3
  end

  test "dynamically supervised tasks" do
    {:ok, pid} = Task.Supervisor.start_link()

    Task.Supervisor.start_child(pid, fn ->
      IO.puts("fire-and-forget this porcess")
    end)

    task =
      Task.Supervisor.async(pid, fn ->
        Process.sleep(500)
        2
      end)

    assert 3 == 1 + Task.await(task)
  end

  test "async_link" do
    {:ok, pid} = Task.Supervisor.start_link()
    assert is_pid(pid)

    t =
      Task.Supervisor.async_nolink(pid, fn ->
        Process.sleep(1000)
        2
      end)

    assert 1 + Task.await(t) == 3
  end
end
