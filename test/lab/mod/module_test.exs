defmodule AMod do
  @modkey1 "val1"

  require Logger

  def val1(), do: @modkey1

  defmacro __using__(_opts) do
    # # __MODULE__ is current module: AMode
    # Logger.debug(
    #   "__using__ macro is running\n__CALLER__: #{inspect(__CALLER__)} \n___MODULE__: #{inspect(__MODULE__)}"
    # )

    # # __CALLER__.module is `use` caller module: ModTest
    # Logger.debug("info: caller.module: #{__CALLER__.module}")

    quote do
      def mod() do
        # todo what is it?
        __MODULE__
      end
    end
  end
end

defmodule ModA do
  defmacro __before_compile__(env) do
    # https://hexdocs.pm/elixir/Macro.Env.html
    # A struct that holds compile time environment information.
    # %{module: mod} = env

    quote do
      # def hello, do: "world"
      def env_in_before_compile, do: unquote(Macro.escape(env))
      def module_in_caller, do: __MODULE__
      def module_when_decalered, do: unquote(__MODULE__)
    end
  end
end

defmodule ModB do
  # https://hexdocs.pm/elixir/Module.html#module-before_compile-1
  @before_compile ModA
end

defmodule ModuleTest do
  use ExUnit.Case

  use AMod

  test "test module attribute" do
    assert "val1" == AMod.val1()
  end

  # test ModTest == ModTest.mod()

  @tag try: true
  test "modules" do
    assert ModB.module_in_caller() == ModB
    assert ModB.module_when_decalered() == ModA

    %{module: env_module} = ModB.env_in_before_compile()
    assert env_module == ModB
    assert ModB.env_in_before_compile().module == ModB
  end
end
