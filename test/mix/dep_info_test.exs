defmodule Mix.DepInfoTest do
  use ExUnit.Case, async: true

  alias Mix.DepInfo

  test "normalizes Hex lock data separately from package latest version" do
    dep = %Mix.Dep{
      scm: Mix.SCM.Hex,
      app: :sample_pkg,
      requirement: "~> 1.0",
      status: {:ok, nil},
      top_level: true,
      opts: [
        dest: "deps/sample_pkg",
        lock:
          {:hex, :sample_pkg, "1.2.3", "checksum", [:mix],
           [{:child_pkg, "~> 2.0", [optional: false]}], "hexpm", "outer_checksum"}
      ]
    }

    info = DepInfo.normalize(dep)

    assert info.app == :sample_pkg
    assert info.top_level
    assert info.package == "sample_pkg"
    assert info.source_type == "Hex"
    assert info.locked_version == "1.2.3"
    assert info.latest_version == nil
    assert info.requirement == "~> 1.0"

    assert info.children == [
             %{
               app: "child_pkg",
               version: "~> 2.0",
               pkg_url: "https://hex.pm/packages/child_pkg"
             }
           ]
  end

  test "normalizes Git source, tag, revision, and sparse path" do
    dep = %Mix.Dep{
      scm: Mix.SCM.Git,
      app: :daisyui,
      status: {:ok, nil},
      opts: [
        git: "https://github.com/saadeghi/daisyui.git",
        dest: "deps/daisyui/packages/bundle",
        checkout: "deps/daisyui",
        lock:
          {:git, "https://github.com/saadeghi/daisyui.git", "revision",
           [tag: "v5.5.20", sparse: "packages/bundle"]}
      ]
    }

    info = DepInfo.normalize(dep)

    assert info.source_type == "Git"
    assert info.source == "https://github.com/saadeghi/daisyui.git"
    assert info.tag == "v5.5.20"
    assert info.revision == "revision"
    assert info.sparse == "packages/bundle"
    assert info.checkout == "deps/daisyui"
    assert info.children == nil
  end

  test "normalizes Path source and Mix status version" do
    dep = %Mix.Dep{
      scm: Mix.SCM.Path,
      app: :local_dep,
      status: {:ok, "0.4.2"},
      opts: [path: "../local_dep", dest: "_build/local_dep", app: true, compile: true]
    }

    info = DepInfo.normalize(dep)

    assert info.source_type == "Path"
    assert info.source == "../local_dep"
    assert info.locked_version == "0.4.2"
    assert info.path == "_build/local_dep"
    assert info.mix_app
    assert info.compile
    assert info.package == nil
  end

  test "Hex enrichment is a no-op for non-Hex dependencies" do
    info = %DepInfo{app: :local_dep, source_type: "Path"}

    assert DepInfo.enrich(info) == {:ok, info}
  end

  test "formats Hex package and child dependency links with locked versions" do
    output =
      Mix.Tasks.H.Dep.Info.format_dep_info(%DepInfo{
        app: :sample_pkg,
        locked_version: "1.2.3",
        pkg_url: "https://hex.pm/packages/sample_pkg",
        docs_url: "https://hexdocs.pm/sample_pkg",
        links: %{"GitHub" => "https://github.com/example/sample_pkg"},
        description: "A sample package",
        path: "deps/sample_pkg",
        children: [
          %{
            app: "child_pkg",
            version: "~> 2.0",
            pkg_url: "https://hex.pm/packages/child_pkg"
          }
        ]
      })

    assert output =~ "sample_pkg 1.2.3"
    assert output =~ "https://hex.pm/packages/sample_pkg"
    assert output =~ "https://hexdocs.pm/sample_pkg"
    assert output =~ "GitHub: https://github.com/example/sample_pkg"
    assert output =~ "child_pkg  https://hex.pm/packages/child_pkg  ~> 2.0"
  end

  test "formats Git dependency source details without an empty dependency section" do
    output =
      Mix.Tasks.H.Dep.Info.format_dep_info(%DepInfo{
        app: :daisyui,
        source_type: "Git",
        source_label: "Repository",
        source: "https://github.com/saadeghi/daisyui.git",
        tag: "v5.5.20",
        revision: "22ecff57f2c391b80a75617325748cf4d13fdf47",
        sparse: "packages/bundle",
        checkout: "/work/deps/daisyui",
        mix_app: false,
        compile: false,
        pkg_url: nil,
        docs_url: nil,
        links: %{},
        description: nil,
        path: "/work/deps/daisyui/packages/bundle",
        children: nil
      })

    assert output =~ "daisyui"
    assert output =~ "Source type: Git"
    assert output =~ "Repository: https://github.com/saadeghi/daisyui.git"
    assert output =~ "Tag: v5.5.20"
    assert output =~ "Commit: 22ecff57f2c391b80a75617325748cf4d13fdf47"
    assert output =~ "Sparse checkout: packages/bundle"
    assert output =~ "Mix application: no"
    assert output =~ "Path: /work/deps/daisyui/packages/bundle"
    refute output =~ "Dependencies (0)"
    refute output =~ "Hex package"
  end
end
