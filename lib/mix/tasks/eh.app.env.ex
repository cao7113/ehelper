defmodule Mix.Tasks.Eh.App.Env do
  @moduledoc """
  Show application env config
  """
  @shortdoc "show application env config"

  use Mix.Task

  @requirements ["app.config"]

  @impl true
  def run(args) do
    app =
      case List.first(args) do
        nil ->
          if Mix.Project.umbrella?() do
            Mix.Project.apps_paths()
            |> Enum.to_list()
            |> List.first()
            |> elem(0)
          else
            detect_main_app()
          end

        a ->
          a |> String.to_atom()
      end

    app
    |> IO.inspect(label: "app name")
    |> Application.get_all_env()
    |> IO.inspect(label: "app config")
  end

  def detect_main_app do
    Mix.Project.config()[:app]
  end
end
