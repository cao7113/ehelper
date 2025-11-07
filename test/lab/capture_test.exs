defmodule CaptureTest do
  use ExUnit.Case

  test "anonymous functions" do
    add = fn x, y -> x + y end
    assert 3 == add.(1, 2)

    mul = fn x, y ->
      x * y
    end

    assert 6 == mul.(2, 3)
  end

  def local_add(x, y) do
    x + y
  end

  test "anonymous fun from other definitions" do
    # get anonymous function from named function
    up = &String.capitalize/1
    assert "Hello" == up.("hello")

    ladd = &local_add/2
    assert 3 == ladd.(1, 2)

    # define anonymous function with capture operator
    add = &(&1 + &2)
    assert 3 == add.(1, 2)

    val = & &1
    assert "hi" == val.("hi")

    list2 = &[&1, &2]
    assert [1, 2] == list2.(1, 2)

    tuple2 = &{&1, &2}
    assert {1, 2} == tuple2.(1, 2)

    map2 = &%{&1 => &2}
    assert %{"a" => 1} == map2.("a", 1)
  end

  test "Emum with anonymous function" do
    lst = Enum.map([1, 2], &(&1 * 2))
    assert [2, 4] == lst
  end
end
