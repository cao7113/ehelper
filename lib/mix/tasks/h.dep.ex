defmodule Mix.Tasks.H.Dep do
  @shortdoc "Show dep info from hex.pm"
  use Mix.Task

  alias Mix.Hex.DepInfo

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
        Mix.raise("invalid name: #{name}")
      end

    info = DepInfo.get_info(pkg, opts)
    info |> Ehelper.pp()
  end
end
