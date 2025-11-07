defmodule TailCallTest do
  use ExUnit.Case

  # sum/1
  def sum(l) do
    do_sum(0, l)
  end

  defp do_sum(total, []), do: total

  defp do_sum(total, [head | tail]) do
    do_sum(total + head, tail)
  end

  test "sum" do
    assert 0 == sum([])
    assert 6 == sum([1, 2, 3])
  end

  # list_len/1
  def list_len(l) do
    do_list_len(0, l)
  end

  defp do_list_len(len, []), do: len

  defp do_list_len(len, [_ | tail]) do
    do_list_len(len + 1, tail)
  end

  test "list_len" do
    assert 0 == list_len([])
    assert 2 == list_len([3, 5])
  end

  # range/2
  def range_list(from, to) do
    do_range([], from, to)
  end

  defp do_range(list, from, from) do
    List.insert_at(list, 0, from)
  end

  defp do_range(list, from, to) do
    do_range(List.insert_at(list, 0, to), from, to - 1)
  end

  test "range/2" do
    assert [1] == range_list(1, 1)
    assert [1, 2, 3, 4] === range_list(1, 4)
  end

  # positive/1
  def positive(l) do
    do_positive([], l)
  end

  defp do_positive(list, []), do: list

  defp do_positive(list, [head | tail]) when head > 0 do
    do_positive([head | list], tail)
  end

  defp do_positive(list, [_ | tail]) do
    do_positive(list, tail)
  end

  test "positive/1" do
    assert [] == positive([])
    assert [2] == positive([2, -1])
    assert [3, 2] == positive([2, -1, 3])
  end
end
