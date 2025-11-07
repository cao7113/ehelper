defmodule DebugTest do
  use ExUnit.Case

  # https://elixir-lang.org/getting-started/debugging.html
  @tag :manual
  test "debug" do
    nums = 1..10

    nums
    |> IO.inspect(label: "nums")
    |> Enum.map(& &1)
    |> IO.inspect(label: "map")
    |> Enum.sum()
    |> IO.inspect(label: "sum")

    sum_it(1, 2) |> IO.inspect(label: "sum_it")

    assert "0x64" == inspect(100, base: :hex)
    assert "0o144" == inspect(100, base: :octal)
  end

  def sum_it(a, b) do
    IO.inspect(binding(), label: "binding")
    a + b
  end
end
