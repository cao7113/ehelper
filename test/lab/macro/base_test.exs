# https://elixir-lang.org/getting-started/meta/macros.html
# https://hexdocs.pm/elixir/Kernel.SpecialForms.html#quote/2

defmodule Math do
  # run at compile time
  # IO.puts("in Math module top level #{__MODULE__}")

  defmacro one, do: 1

  defmacro squared(x) do
    quote do
      unquote(x) * unquote(x)
    end
  end

  ## modules

  # __MODULE__ == Math
  defmacro get_mod do
    __MODULE__
  end

  # here __MODULE__ == BaseTest the required module
  defmacro quoted_mod do
    quote do
      # this is in the execution env module
      __MODULE__
    end
  end

  defmacro ref_mod_value do
    quote do
      # ref current macro env value
      # that is Math
      unquote(__MODULE__)
    end
  end

  defmacro caller_mod do
    # only used in macro env, but is the real caller module
    __CALLER__.module
  end
end

defmodule BaseTest do
  use ExUnit.Case

  require Math
  import Math

  test "mod" do
    assert get_mod() == Math
    assert quoted_mod() == __MODULE__
    assert quoted_mod() == BaseTest
    assert ref_mod_value() == Math
    assert caller_mod() == __MODULE__
  end

  test "macro work after require or import module" do
    assert 1 == Math.one()
    assert 1 == one()
    assert squared(3) == 9
  end
end
