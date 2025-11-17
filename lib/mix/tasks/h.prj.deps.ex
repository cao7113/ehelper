defmodule Mix.Tasks.H.Prj.Deps do
  @shortdoc "Show project deps config"

  @moduledoc """
  #{@shortdoc}.

  ## Options
  - raw: raw deps config
  """

  use Mix.Task

  @switchs [raw: :boolean]
  @aliases [r: :raw]

  @impl true
  def run(args) do
    prj_mod = Mix.Project.get!()

    {opts, _args} = OptionParser.parse!(args, strict: @switchs, aliases: @aliases)
    raw? = opts[:raw] && function_exported?(prj_mod, :raw_deps, 0)

    if raw? do
      prj_mod.raw_deps()
    else
      Mix.Project.config()[:deps]
    end
    |> Ehelper.pp()
  end
end
