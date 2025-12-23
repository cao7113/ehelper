defmodule Mix.Tasks.H.Pkg do
  @shortdoc "Show hex dep meta-info from hex.pm"
  @moduledoc """
  #{@shortdoc}.

  This task fetches and displays dependency information from hex.pm.

  Like mix hex.info ehelper
  """

  use Mix.Task

  alias Mix.PkgInfo

  @switches [
    force: :boolean,
    file_cache: :boolean
  ]

  @aliases [
    f: :force,
    c: :file_cache
  ]

  @impl true
  def run(args) do
    {opts, args, _error} = OptionParser.parse(args, switches: @switches, aliases: @aliases)
    pkg = args |> List.first()

    pkg =
      if pkg do
        pkg |> String.trim()
      else
        Mix.raise("Require dependency name!")
      end

    info = PkgInfo.get_info(pkg, opts)
    info |> Ehelper.pp()
  end
end
