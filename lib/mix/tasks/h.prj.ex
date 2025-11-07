defmodule Mix.Tasks.H.Prj do
  @shortdoc "Show project config"
  use Mix.Task

  @impl true
  def run(_args) do
    Mix.Project.get!()
    Mix.Project.config() |> IO.inspect(label: "mix project")
  end
end
