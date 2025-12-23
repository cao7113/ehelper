defmodule Mix.Tasks.H.Pkg.Stat do
  @shortdoc "Local cached packages meta-info stats managed by ehelper"
  @moduledoc """
  #{@shortdoc}.

  Options:
  - force: force fetching of dependency information
  """

  use Mix.Task
  alias Mix.PkgInfo

  @switches [
    force: :boolean
  ]

  @aliases [f: :force]

  @impl true
  def run(args) do
    {_opts, _, _} = OptionParser.parse(args, strict: @switches, aliases: @aliases)

    root = PkgInfo.dep_cache_root()
    files = Path.wildcard("#{root}/*.json")
    names = files |> Enum.map(&Path.basename(&1, ".json"))
    timings = File.stat!(root, time: :local) |> Map.take([:atime, :mtime, :ctime])

    info = %{
      root: root,
      disk_in_kb: Ehelper.File.du_ksize(root),
      rand_names: names |> Enum.take_random(5),
      timings: timings,
      files_count: Enum.count(names)
    }

    info |> Ehelper.pp()
  end
end
