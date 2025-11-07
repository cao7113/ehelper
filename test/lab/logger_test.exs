defmodule LoggerTest do
  use ExUnit.Case

  import Logger

  @tag :manual
  test "logger level" do
    # Note: all those methods are macros
    info("this is info message")
    debug("this is debug message")
    warning("this is warn message")
    error("this is error message")
  end
end
