defmodule Mix.Tasks.H.Git.Ops.Types do
  @shortdoc "Show git_ops types"
  use Mix.Task

  @requirements ["app.config"]

  @impl true
  def run(_args) do
    GitOps.Config.types()
    |> IO.inspect(label: "git_ops types", pretty: true)
  end
end
