defmodule Mix.Tasks.H.Dep.Unlink do
  @shortdoc "Unlink dep code from local repository in _repos/"

  @moduledoc """
  #{@shortdoc}.

  support unlinking multiple deps at once, eg. `mix h.dep.unlink phoenix ecto`

  Options:
    * `--link-target-root`, `-r` - root directory to create link targets, default to `deps/`
    * `--link-suffix`, `-s` - suffix for link target names, default to `link`
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
    {opts, args, _error} = OptionParser.parse(args, switches: @switches, aliases: @aliases)

    shell = Mix.shell()

    args
    |> Enum.each(fn pkg ->
      pkg = pkg |> String.trim()
      link_target = DepLink.get_link_target(pkg, opts)

      if File.exists?(link_target) do
        File.rm!(link_target)
        shell.info("-- #{pkg}: unlinked #{link_target}")
      else
        shell.info("-- #{pkg}: #{link_target} does not exist, skipped")
      end
    end)
  end
end
