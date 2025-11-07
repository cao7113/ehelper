defmodule Counter do
  use Agent

  def start_link(initial_value) do
    Agent.start_link(fn -> initial_value end, name: __MODULE__)
  end

  def value do
    Agent.get(__MODULE__, & &1)
  end

  def increment do
    Agent.update(__MODULE__, &(&1 + 1))
  end
end

defmodule CounterTest do
  use ExUnit.Case

  test "try" do
    {:ok, _pid} = Counter.start_link(0)
    assert 0 == Counter.value()

    Task.start_link(fn ->
      Counter.increment()
    end)

    Counter.increment()
    Counter.increment()
    assert 3 == Counter.value()
  end
end
