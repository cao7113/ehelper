defmodule EhelperTest do
  use ExUnit.Case
  doctest Ehelper

  test "greets the world" do
    assert Ehelper.hello() == :world
  end
end
