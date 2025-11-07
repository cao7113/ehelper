defmodule EnumTest do
  use ExUnit.Case
  import Enum

  test "basic ussage" do
    # map
    assert [1] |> Enum.map(&(&1 + 1)) == [2]

    # zip
    assert ~w[b c]a |> Enum.zip(2..3) == [b: 2, c: 3]

    assert ~w(ab cde f) |> sort(&(String.length(&1) <= String.length(&2))) == ~w[f ab cde]

    assert 1..3 |> into([]) == [1, 2, 3]
  end

  test "Enum.reduce then reverse pattern" do
    assert 2..4 |> Enum.reduce([], &[&1 + 1 | &2]) |> Enum.reverse() == [3, 4, 5]
  end
end
