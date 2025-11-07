defmodule EtsTest do
  use ExUnit.Case

  test "ets" do
    table = :ets.new(:ets_test, [])
    # Store as tuples with {name, population}
    :ets.insert(table, {"China", 1_374_000_000})
    :ets.insert(table, {"India", 1_284_000_000})
    :ets.insert(table, {"USA", 322_000_000})

    # :ets.i(table)
    # |> IO.inspect(label: "ets")
  end
end
