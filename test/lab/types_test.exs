defmodule TypesTest do
  use ExUnit.Case

  ## Boolean
  test "falsy cases only false or nil" do
    assert !false
    assert !nil
    refute false
    refute nil
  end

  test "truthy cases" do
    assert 1
    assert :ok
    assert "t"
  end

  ## String

  test "join strings" do
    assert "hel" <> "lo" == "hello"
  end

  ## Keyword
  # https://hexdocs.pm/elixir/Keyword.html#content

  test "keyword list" do
    kw = [name: :geek, age: 3]
    assert kw[:name] == :geek
    assert Access.get(kw, :age) == 3

    assert is_list(kw)
  end

  ## List

  # https://hexdocs.pm/elixir/List.html#content

  test "list" do
    [head | tail] = [1, 2, 3]
    assert head == 1
    assert tail == [2, 3]
    assert is_list(tail)
    assert 2 == length(tail)
  end

  ## Map
  test "basic map" do
    m = %{this_is_a_key: "val1"}
    assert is_map(m)
    assert m.this_is_a_key == "val1"

    m = Map.put(m, :id, 1)
    assert 1 == m.id
    # fail when name not exists
    # m1 = %{m | name: "test"}
    # assert "test" === m1.name

    m = %{a: 3}
    assert {3, %{}} == Map.pop(m, :a)
  end

  defmodule TUser do
    defstruct [:name]
  end

  test "from_struct" do
    u = %TUser{name: "hi"}
    assert %{name: "hi"} == Map.from_struct(u)
  end

  ## Tuple
  # https://hexdocs.pm/elixir/Tuple.html#content

  test "basic tuple" do
    {_, a} = {:ok, "a"}
    assert "a" == a
  end

  test "tuple functions" do
    t = {:ok, "a", 1}
    assert elem(t, 1) == "a"
    assert tuple_size(t) == 3
  end
end
