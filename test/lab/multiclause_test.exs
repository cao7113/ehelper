defmodule MultiClauseTest do
  use ExUnit.Case

  # factorial
  def fact(0), do: 1
  def fact(n), do: n * fact(n - 1)

  test "fact" do
    assert 1 === fact(0)
    assert 2 == fact(2)
  end

  # sum
  def sum([]), do: 0
  def sum([head | tail]), do: head + sum(tail)

  test "sum" do
    assert sum([]) == 0
    assert sum([1, 2, 3]) == 6
  end
end
