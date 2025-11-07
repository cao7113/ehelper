defmodule Ehelper.App do
  @moduledoc """
  Application helpers
  """

  def current_app, do: Application.get_application(__MODULE__)

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

  def app_env(app \\ current_app()), do: Application.get_all_env(app)

  def restart(app \\ current_app()) do
    Application.stop(app)
    Application.start(app)
  end

  def started?(app) when is_atom(app) do
    Application.started_applications()
    |> Enum.any?(fn {a, _desc, _ver} -> a == app end)
  end
end
