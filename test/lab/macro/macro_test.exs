# https://elixir-lang.org/getting-started/meta/macros.html
# https://hexdocs.pm/elixir/Kernel.SpecialForms.html#quote/2

defmodule Math do
  # run when compile
  # IO.puts("in Math module top level #{__MODULE__}")

  defmacro squared(x) do
    IO.puts("in macro module #{__MODULE__}")

    quote do
      IO.puts("in quote context module #{__MODULE__}")
      unquote(x) * unquote(x)
    end
  end
end

defmodule MacroTest do
  use ExUnit.Case

  require Math
  # import Math

  # test "try with" do
  #   assert squared(3) == 9
  # end
end
