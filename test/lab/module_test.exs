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

defmodule ModTest do
  use ExUnit.Case

  use AMod

  test "test module attribute" do
    assert "val1" == AMod.val1()
  end

  # test ModTest == ModTest.mod()
end
