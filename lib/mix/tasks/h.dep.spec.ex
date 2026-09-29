defmodule Mix.Tasks.H.Dep.Spec do
  @shortdoc "Show spec for one dependency"

  @moduledoc """
  #{@shortdoc}.

  ## Examples

      mix h.dep.spec req
      mix h.dep.spec plug --env-target
      mix h.dep.spec req -e

  The dependency name must exactly match the dependency application's name,
  including case. The output omits dependency lists and loaded module names,
  replacing those fields with `:skipped`.

  ## Options

    * `--env-target`, `-e` - converge dependencies for the current environment
      and target instead of using the default dependency set.
  """

  use Mix.Task
  alias Mix.DepInfo

  @switches [env_target: :boolean]
  @aliases [e: :env_target]

  @impl true
  def run(args) do
    Mix.Project.get!()

    {opts, dep_names} = OptionParser.parse!(args, strict: @switches, aliases: @aliases)

    dep_name =
      case dep_names do
        [dep_name] -> dep_name
        _ -> Mix.raise("require exactly one dep-app name like: mix h.dep.spec req")
      end

    DepInfo.find(dep_name, env_target: opts[:env_target])
    |> case do
      {:ok, dep} ->
        dep
        |> Map.from_struct()
        |> Map.put(:deps, [:skipped])
        |> case do
          %{scm: Hex.SCM} = info ->
            info
            |> put_in([:opts, :app_properties, :modules], [:skipped])

          %{scm: Mix.SCM.Git} = info ->
            info

          _ = info ->
            info
        end
        |> Map.to_list()
        |> Enum.sort()
        |> Ehelper.pp()

      {:error, message} ->
        Mix.shell().error(message)
    end
  end
end
