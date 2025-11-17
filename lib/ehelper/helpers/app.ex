defmodule Ehelper.App do
  @moduledoc """
  Application helpers
  """

  def get_app(mod \\ __MODULE__) when is_atom(mod), do: Application.get_application(mod)

  def apps(kind \\ :started) do
    case kind do
      :started ->
        Application.started_applications()

      :loaded ->
        Application.loaded_applications()

      _ ->
        nil
    end
    |> Enum.sort()
  end

  def app_names(kind \\ :started) do
    apps(kind)
    |> Enum.map(fn {app, _desc, _ver} -> app end)
  end

  def app_env(app \\ get_app()), do: Application.get_all_env(app)

  def restart(app \\ get_app()) do
    Application.stop(app)
    Application.start(app)

    # System.restart()
  end

  def started?(app) when is_atom(app) do
    Application.started_applications()
    |> Enum.any?(fn {a, _desc, _ver} -> a == app end)
  end
end
