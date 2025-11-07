defmodule TryTest do
  require Logger
  use ExUnit.Case, async: true

  # callback
  setup context do
    # run before each test
    {:ok, Map.put(context, :info1, "shared-info-from-callback")}
  end

  # mix test test/try_test.exs --include manual
  # tag register info into context for used in callback
  @tag :manual
  @tag :capture_log
  test "context shared info between callbacks and tests", ctx = %{info1: info1} do
    IO.inspect(ctx, label: "context info")
    Logger.info("this log info will be suppressed")
    assert info1 == "shared-info-from-callback"
  end

  @tag :external
  test "mock test depends on external info" do
    assert true
  end

  @tag skip: "testing"
  test "not run this test" do
    assert true
  end

  # test "this will be a test in future"
end
