defmodule QuotedExpressionTest do
  use ExUnit.Case

  test "quote values" do
    # lietral integers
    f = quote do: 1
    assert f == 1

    f = quote do: {1, 2}
    # only two elements tuple
    assert {1, 2} == f

    f = quote do: {1}
    assert {:{}, [], [1]} == f
    f = quote do: {1, 2, 3}
    assert {:{}, [], [1, 2, 3]} == f

    f = quote do: %{a: 1}
    assert {:%{}, [], [a: 1]} == f
  end

  test "unquote" do
    foo =
      quote do
        2
      end

    bar =
      quote do
        sum(1, unquote(foo), 3)
      end

    assert {:sum, [], [1, 2, 3]} == bar
  end

  test "unquote splicing list" do
    l = [2, 3]

    q =
      quote do
        sum(1, unquote_splicing(l))
      end

    assert {:sum, [], [1, 2, 3]} == q
  end

  test "Macro.escape/2" do
    m = %{a: 1}
    # ** (ArgumentError) tried to unquote invalid AST: %{a: 1}
    # f = quote do: unquote(m)

    # map should escaped before unquoting
    e = quote do: unquote(Macro.escape(m))
    assert {:%{}, [], [{:a, 1}]} == e
  end

  test "Macro.to_string/1" do
    ast = quote(do: var)
    assert ast == {:var, [], QuotedExpressionTest}
    assert Macro.to_string(ast) == "var"
  end
end
