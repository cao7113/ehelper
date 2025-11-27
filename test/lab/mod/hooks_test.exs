defmodule Hooks do
  defmacro __before_compile__(%{module: mod}) do
    quote do
      def hi(), do: :ok
      def get_mod, do: unquote(mod)
    end
  end
end

defmodule HooksTest do
  @moduledoc """
  - https://hexdocs.pm/elixir/1.19.3/Module.html#module-before_compile-1
  Accepts a module or a {module, function_or_macro_name} tuple.
  The function/macro must take one argument: the module environment.
  If it's a macro, its returned value will be injected at the end of the module definition before the compilation starts.
  When just a module is provided, the function/macro is assumed to be __before_compile__/1.
  Note: the callback function/macro must be placed in a separate module (because when the callback is invoked, the current module does not yet exist).
  """

  use ExUnit.Case

  @before_compile Hooks

  test "@before_compile" do
    assert hi() == :ok
    assert get_mod() == __MODULE__
    assert get_mod() == HooksTest
  end
end
