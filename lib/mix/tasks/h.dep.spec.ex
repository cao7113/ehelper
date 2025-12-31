defmodule Mix.Tasks.H.Dep.Spec do
  @shortdoc "Show project locked-deps spec"

  @moduledoc """
  #{@shortdoc}.

  ## Example
  - mix h.dep.spec req

  ## Options:
  - env_target: use current env and target
  """

  use Mix.Task

  @switches [env_target: :boolean]
  @aliases [e: :env_target]

  @impl true
  def run(args) do
    Mix.Project.get!()

    {opts, names} = OptionParser.parse!(args, strict: @switches, aliases: @aliases)
    if names == [], do: Mix.raise("require dep-app names like: mix h.deps.spec req plug")
    loaded_opts = if opts[:env_target], do: [env: Mix.env(), target: Mix.target()], else: []

    Mix.Dep.Converger.converge(loaded_opts)
    |> Enum.filter(fn %{app: dep_app} ->
      dep_app = Atom.to_string(dep_app)

      Enum.any?(names, fn n ->
        String.contains?(dep_app, n)
      end)
    end)
    |> Enum.map(fn dep ->
      dep
      |> Map.from_struct()
      |> put_in([:deps], [:skipped])
      |> put_in([:opts, :app_properties, :modules], [:skipped])
      |> Map.to_list()
      |> Enum.sort()
    end)
    |> Ehelper.pp()
  end
end
