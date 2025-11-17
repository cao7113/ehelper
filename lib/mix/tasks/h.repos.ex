defmodule Mix.Tasks.H.Repos do
  @shortdoc "Summarize local repos stats managed by ehelper"

  @moduledoc """
  #{@shortdoc}.

  Options:
  - force: force fetching of dependency information
  """

  use Mix.Task
  alias Mix.RepoInfo

  @switches [
    force: :boolean
  ]

  @aliases [
    f: :force
  ]

  @impl true
  def run(args) do
    {_opts, _, _} = OptionParser.parse(args, strict: @switches, aliases: @aliases)

    root = RepoInfo.local_repos_root()
    files = File.ls!("#{root}/")
    names = files |> Enum.map(&Path.basename(&1))
    timings = File.stat!(root, time: :local) |> Map.take([:atime, :mtime, :ctime])

    info = %{
      root: root,
      disk_in_kb: Ehelper.File.du_ksize(root),
      rand_names: names |> Enum.take_random(5),
      timings: timings,
      repos_count: Enum.count(names)
    }

    info |> Ehelper.pp()
  end
end
