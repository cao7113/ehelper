defmodule Ehelper.App do
  @moduledoc """
  Application helpers
  """

  def app_names(opts \\ []) do
    opts
    |> Keyword.put_new(:sort, true)
    |> get_apps()
    |> Enum.map(fn {app, _desc, _ver} ->
      app
    end)
  end

  def spec(app \\ :mix) when is_atom(app) do
    Application.spec(app)
    |> then(fn
      nil ->
        nil

      opts ->
        mods = opts[:modules] || []

        mods_len = length(mods)
        hd_mod = List.first(mods)
        path = :code.which(hd_mod) |> to_string() |> Path.dirname()

        if length(mods) <= 3 do
          opts
        else
          Keyword.put(opts, :modules, Enum.take(mods, 3) ++ ["#{mods_len - 3}..."])
        end
        |> Keyword.put(:load_path, path)
        |> Keyword.put(:started?, started?(app))

        # |> Enum.sort()
    end)
  end

  def spec_of(app, key) do
    Application.spec(app, key)
  end

  def get_app(mod \\ __MODULE__) when is_atom(mod) do
    Application.get_application(mod)
  end

  def find_app(app, opts \\ []) when is_atom(app) do
    opts
    |> get_apps()
    |> Enum.find(fn {a, _, _} ->
      a == app
    end)
  end

  def get_apps(opts \\ []) do
    kind = Keyword.get(opts, :kind, :started)
    sort? = Keyword.get(opts, :sort, false)

    case kind do
      :started ->
        Application.started_applications()

      :loaded ->
        Application.loaded_applications()

      _ ->
        []
    end
    |> then(fn apps ->
      if sort?, do: Enum.sort(apps), else: apps
    end)
  end

  def app_env(app \\ get_app()), do: Application.get_all_env(app)

  def restart(app \\ get_app()) do
    Application.stop(app)
    Application.start(app)

    # System.restart()
  end

  def started?(app, opts \\ []) when is_atom(app) do
    opts
    |> Keyword.put(:kind, :started)
    |> get_apps()
    |> Enum.any?(fn {a, _desc, _ver} -> a == app end)
  end

  @doc """
  Check all app started, or raise error
  """
  def ensure_all_started!(apps) do
    Application.ensure_all_started(apps)
    |> case do
      {:ok, _} ->
        :ok

      {:error, {app, reason}} when is_atom(app) ->
        # ** (ArgumentError) raise/1 and reraise/2 expect a module name, string or exception as the first argument, got: {:abc, {~c"no such file or directory", ~c"abc.app"}}
        raise "No [#{app}] app, because #{reason |> inspect()}"

      {:error, reason} ->
        raise reason |> inspect()
    end
  end
end
