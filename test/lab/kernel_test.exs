defmodule KernelTest do
  use ExUnit.Case

  @moduletag :try

  test "apply" do
    assert apply(Enum, :reverse, [[1, 2, 3]]) == [3, 2, 1]
  end

  test "__ENV__" do
    assert __ENV__.module == KernelTest
    assert is_struct(__ENV__, Macro.Env)
  end

  test "__ENV__.function" do
    assert env_func() == {:env_func, 0}
  end

  def env_func do
    # this is current function as {:function_name_as_atom, :arity}
    __ENV__.function
  end

  # https://hexdocs.pm/elixir/1.19.2/Kernel.SpecialForms.html#quote/2-hygiene-in-variables

  defmodule Hygiene do
    defmacro no_interference do
      quote do
        a = 1
      end
    end
  end

  defmodule NoHygiene do
    defmacro interference do
      quote do
        # If you want to set or get a variable in the caller's context,
        # you can do it with the help of the var! macro:
        var!(a) = 2
      end
    end
  end

  test "var!" do
    a = 10
    require Hygiene
    Hygiene.no_interference()
    # not 1 in no_interference
    assert a == 10

    require NoHygiene
    NoHygiene.interference()
    assert a == 2
  end
end
