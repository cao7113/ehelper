defmodule Mix.Tasks.H.Deps.Links do
  @shortdoc "List local deps links to repositories in _repos/"

  @moduledoc """
  #{@shortdoc}.

  support unlinking multiple deps at once, eg. `mix h.dep.links`

  Options:
    * `--link-root`, `-r` - root directory to create link targets, default to `deps/`
    * `--link-suffix`, `-s` - suffix for link target names, default to `link`

  Other Commands:
  - `find deps -maxdepth 1 -type l -print`
  - `ls -l deps | grep '^l'`
  """

  use Mix.Task
  alias Mix.DepLink

  @switches [
    link_root: :string,
    link_suffix: :string
  ]

  @aliases [
    r: :link_root,
    s: :link_suffix
  ]

  @impl true
  def run(args) do
    {opts, _args, _error} = OptionParser.parse(args, switches: @switches, aliases: @aliases)

    links_root = DepLink.get_link_root(opts)
    shell = Mix.shell()
    glob = "#{links_root}/*"

    items =
      Path.wildcard(glob)
      |> Enum.filter(fn d -> Ehelper.File.is_link?(d) end)

    shell.info("# #{Enum.count(items)} dep links with glob: #{glob}")

    max_letter =
      items
      |> Enum.map(fn d -> String.length(d) end)
      |> Enum.max()

    items
    |> Enum.sort()
    |> Enum.map(fn d ->
      target = File.read_link!(d)
      space_num = max_letter - String.length(d)
      spaces = String.duplicate(" ", space_num)
      shell.info("* #{d}#{spaces} -> #{target}")
    end)

    # cmd = "find #{links_root} -type l -depth 1 -exec ls -l {} \\;"
    # Mix.shell().info("# cmd: #{cmd}")
    # System.shell(cmd)
    # |> case do
    #   {msg, 0} -> IO.puts(msg)
    #   {"", 1} -> IO.puts("No dep links")
    #   other -> other |> Ehelper.pp()
    # end
  end
end
