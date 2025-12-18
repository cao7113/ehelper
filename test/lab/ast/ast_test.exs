defmodule AstDemo do
  def sum2(a, b), do: a + b

  defmacro mock_sum(a, b) do
    # direct mock an ast tuple struct
    {:sum2, [], [a, b]}
  end

  defmacro bind_quoted(opts \\ []) do
    quote bind_quoted: [opts: opts] do
      opts
    end
  end

  defmacro quote_back(opts \\ []) do
    quote do
      unquote(opts)
    end
  end

  defmacro add1(a) do
    quote do
      # a + 1
      # use unquote ref quote block outside variable called a
      unquote(a) + 1
    end
  end

  defmacro add2(a) do
    quote do
      var!(a) = unquote(a)
      var!(a) + 2
    end
  end
end

defmodule AstTest do
  use ExUnit.Case

  # @moduletag :try

  # https://hexdocs.pm/elixir/quote-and-unquote.html#quoting
  # https://hexdocs.pm/elixir/1.19.2/Kernel.SpecialForms.html#quote/2-elixir-s-ast-abstract-syntax-tree
  # Any Elixir code can be represented using Elixir data structures.
  # The building block of Elixir macros is a tuple with three elements
  # https://hexdocs.pm/elixir/Macro.html#t:metadata/0

  # AST 3-element tuple: {atom | tuple_like, list, list | atom}
  # The first element is an atom or another tuple in the same representation;
  # The second element is a keyword list containing metadata, like numbers and contexts;
  # The third element is either a list of arguments for the function call or an atom. When this element is an atom, it means the tuple represents a variable.

  test "ast literals" do
    # :sum         #=> Atoms
    # 1            #=> Integers
    # 2.0          #=> Floats
    # [1, 2]       #=> Lists
    # "strings"    #=> Strings
    # {key, value} #=> Tuples with two elements
    assert quote(do: :sum) == :sum
    assert Macro.escape(:sum) == :sum
    assert Macro.to_string(:sum) == ":sum"
  end

  test "other quoted value equal Macro.escape/1" do
    assert quote(do: %{a: 3}) == {:%{}, [], [a: 3]}
    assert Macro.escape(%{a: 3}) == {:%{}, [], [a: 3]}

    # Variables are represented using such triplets, with the difference that the last element is an atom, instead of a list:
    assert quote(do: x) == {:x, [], __MODULE__}
  end

  # When quoting more complex expressions, we can see that the code is represented in such tuples,
  #  which are often nested inside each other in a structure resembling a tree.
  # Many languages would call such representations an Abstract Syntax Tree (AST).
  # Elixir calls them “QUOTED EXPRESSIONS”
  test "complex" do
    ast = quote do: sum(1, 2 + 3, 4)
    # {:sum, [], [1, {:+, [context: AstTest, imports: [{1, Kernel}, {2, Kernel}]], [2, 3]}, 4]}
    {:sum, [], [1, {:+, _metadata, [2, 3]}, 4]} = ast
    assert Macro.to_string(ast) == "sum(1, 2 + 3, 4)"
  end

  test "mock ast" do
    import AstDemo
    assert AstDemo.mock_sum(1, 2) == 3

    assert AstDemo.bind_quoted(%{a: 1}) == %{a: 1}
    assert AstDemo.quote_back(%{a: 1}) == %{a: 1}

    assert AstDemo.add1(1) == 2
    assert AstDemo.add2(1) == 3
  end
end
