defmodule KernelTest do
  use ExUnit.Case

  test "apply" do
    assert [3, 2, 1] == apply(Enum, :reverse, [[1, 2, 3]])
  end
end
