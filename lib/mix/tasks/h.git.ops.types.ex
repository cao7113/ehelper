defmodule Mix.Tasks.H.Git.Ops.Types do
  @shortdoc "Show git_ops types"
  use Mix.Task

  @requirements ["app.config"]
  @compile {:no_warn_undefined, GitOps.Config}

  @impl true
  def run(_args) do
    if Code.loaded?(GitOps) do
      GitOps.Config.types()
      |> IO.inspect(label: "git_ops types", pretty: true)
    else
      Mix.shell().error("git_ops is not loaded. Please run in :dev environment.")
    end
  end
end
