defmodule Mix.PkgInfoTest do
  use ExUnit.Case, async: false

  alias Mix.PkgCache

  setup do
    cache_root =
      Path.join(System.tmp_dir!(), "ehelper-pkg-cache-#{System.unique_integer([:positive])}")

    previous_root = System.get_env("MIX_PKGS_INFO_ROOT")
    System.put_env("MIX_PKGS_INFO_ROOT", cache_root)

    on_exit(fn ->
      if previous_root do
        System.put_env("MIX_PKGS_INFO_ROOT", previous_root)
      else
        System.delete_env("MIX_PKGS_INFO_ROOT")
      end

      File.rm_rf!(cache_root)
    end)

    {:ok, cache_root: cache_root}
  end

  test "loads cached package metadata without a network request", %{cache_root: cache_root} do
    File.mkdir_p!(cache_root)

    File.write!(
      Path.join(cache_root, "sample_pkg.json"),
      JSON.encode!(%{
        "name" => "sample_pkg",
        "latest_version" => "1.2.3",
        "meta" => %{
          "description" => "A sample package",
          "links" => %{"GitHub" => "https://github.com/example/sample_pkg"}
        },
        "docs_html_url" => "https://hexdocs.pm/sample_pkg",
        "html_url" => "https://hex.pm/packages/sample_pkg",
        "url" => "https://hex.pm/api/packages/sample_pkg",
        "downloads" => %{"all" => 12}
      })
    )

    info = PkgCache.get_info("sample_pkg")

    assert info.app == "sample_pkg"
    assert info.latest_version == "1.2.3"
    assert info.desc == "A sample package"
    refute Map.has_key?(Map.from_struct(info), :channel)
    refute Map.has_key?(Map.from_struct(info), :cache_path)
  end
end
