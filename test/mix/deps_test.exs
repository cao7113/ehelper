defmodule Mix.DepsTest do
  use ExUnit.Case, async: true

  alias Mix.DepInfo
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

  test "dependency output distinguishes the locked version from Hex latest" do
    output =
      Deps.get_dep_doc(
        %DepInfo{
          app: :plug,
          source_type: "Hex",
          locked_version: "1.2.3",
          latest_version: "1.3.0",
          description: "Composable modules",
          pkg_url: "https://hex.pm/packages/plug"
        },
        0
      )

    assert output =~ "#1 plug (locked: 1.2.3, latest: 1.3.0)"
    assert output =~ "Composable modules"
    assert output =~ "https://hex.pm/packages/plug"
  end

  test "dependency output includes source details for non-Hex dependencies" do
    output =
      Deps.get_dep_doc(
        %DepInfo{
          app: :daisyui,
          source_type: "Git",
          source: "https://github.com/saadeghi/daisyui.git",
          tag: "v5.5.20",
          path: "deps/daisyui/packages/bundle"
        },
        0
      )

    assert output =~ "Source type: Git"
    assert output =~ "Source: https://github.com/saadeghi/daisyui.git"
    assert output =~ "Tag: v5.5.20"
    refute output =~ "latest:"
  end
end
