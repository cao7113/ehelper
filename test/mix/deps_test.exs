defmodule Mix.DepsTest do
  use ExUnit.Case, async: true

  alias Mix.Tasks.H.Deps

  test "search matches whole words in dependency names only" do
    assert Deps.matches_search?("ash", "ash")
    assert Deps.matches_search?("my_ash_tools", "ash")
    refute Deps.matches_search?("phoenix_live_dashboard", "ash")
    refute Deps.matches_search?("cash_app", "ash")
  end

  test "search ignores case and matches phrases in names" do
    assert Deps.matches_search?("Ash_dashboard", "Ash")
    assert Deps.matches_search?("Ash_dashboard", "ash")
    assert Deps.matches_search?("phoenix_live_dashboard", "live_dashboard")
    refute Deps.matches_search?("phoenix_live_dashboard", "ash")
  end
end
