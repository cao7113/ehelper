defmodule Mix.Tasks.H.Dep.Meta do
  @shortdoc "Show hex dep meta-info from hex.pm"
  @moduledoc """
  #{@shortdoc}.

  This task fetches and displays dependency information from hex.pm.
  """

  use Mix.Task

  alias Mix.DepInfo

  @switches [
    force: :boolean
  ]

  @aliases [
    f: :force
  ]

  @impl true
  def run(args) do
    {opts, args, _error} = OptionParser.parse(args, switches: @switches, aliases: @aliases)
    name = args |> List.first()

    pkg =
      if name do
        name |> String.trim()
      else
        Mix.raise("Require dependency name!")
      end

    info = DepInfo.get_info(pkg, opts)
    info |> Ehelper.pp()
  end
end
