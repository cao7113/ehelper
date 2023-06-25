defmodule Mix.Tasks.Eh.Prj do
  @moduledoc """
  Project config info
  """
  @shortdoc "show project config"
  use Mix.Task

  @impl true
  def run(_args) do
    Mix.Project.config() |> IO.inspect(label: "mix project")
  end
end
