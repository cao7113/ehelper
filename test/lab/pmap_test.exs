defmodule ParallelMap do
  def map(col, fun) do
    parent = self()

    ps =
      Enum.map(col, fn e ->
        spawn_link(fn ->
          p = self()
          send(parent, {p, fun.(e)})
        end)
      end)

    ps
    |> Enum.map(fn p ->
      receive do
        {^p, result} -> result
      end
    end)
  end

  def slow_dobule(x) do
    :timer.sleep(10)
    2 * x
  end
end

defmodule ParallelMapTest do
  use ExUnit.Case

  @moduletag :manual

  test "p-map" do
    result =
      1..100
      |> ParallelMap.map(fn x ->
        :timer.sleep(Enum.random(1..200))
        x
      end)
      |> IO.inspect(label: "result")

    assert result == 1..100 |> Enum.to_list()
  end

  test "perf" do
    :timer.tc(fn ->
      1..20
      |> ParallelMap.map(&ParallelMap.slow_dobule/1)
    end)
    |> IO.inspect(label: "ParallelMap.map")

    :timer.tc(fn ->
      1..20
      |> Enum.map(&ParallelMap.slow_dobule/1)
    end)
    |> IO.inspect(label: "Enum.map")
  end
end
