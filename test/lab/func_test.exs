defmodule FuncTest do
  use ExUnit.Case

  test "_ special underscore to ignore something" do
    assert get_chain("a", nil) == "just-a"
    assert get_chain("b") == "just-b"

    assert get_chain("a", "c") == "a-on-c"
  end

  def get(uuid) do
    "just-#{uuid}"
  end

  def get_chain(uuid, chain \\ nil) do
    if chain do
      "#{uuid}-on-#{chain}"
    else
      get(uuid)
    end
  end
end
