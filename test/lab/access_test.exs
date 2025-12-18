defmodule AccessTest do
  use ExUnit.Case

  test "usage" do
    m = %{}
    assert is_nil(m[:missing][:nest_again])

    assert is_nil(nil[:a])
  end
end
