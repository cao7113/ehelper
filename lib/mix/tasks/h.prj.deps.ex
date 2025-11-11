defmodule Mix.Tasks.H.Prj.Deps do
  @shortdoc "Show project deps"
  use Mix.Task

  @impl true
  def run(_args) do
    Mix.Project.get!()

    Mix.Project.config()[:deps]
    |> Ehelper.pp()
  end
end
