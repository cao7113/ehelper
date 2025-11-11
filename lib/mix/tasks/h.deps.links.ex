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
    links_pattern = DepLink.get_links_pattern(opts)

    # Path.wildcard(Path.join(link_root, patten))
    # |> Ehelper.pp()

    System.shell("ls -al #{links_pattern} 2>/dev/null")
    |> case do
      {msg, 0} -> IO.puts(msg)
      {"", 1} -> IO.puts("No dep links")
      other -> other |> Ehelper.pp()
    end
  end
end
