defmodule Mix.Tasks.H.Dep do
  use Mix.Task

  @shortdoc "Displays dependency information include child dependencies."

  @moduledoc """
  This task displays detailed information about a specified dependency, including:
  - Basic metadata: name, version, source URL, description.
  - Child dependencies: versions and descriptions.
  - Additional metadata from README.md or CHANGELOG.md (if available).
  """

  @requirements ["app.start"]
  # Mix.Task.run("deps.loadpaths", [])

  @impl Mix.Task
  def run([dep_name]) do
    dep_name
    |> String.to_atom()
    |> fetch_dep_info()
    |> print_dep_info()
  end

  def run(_) do
    Mix.shell().info("Usage: mix l.dep <dependency>")
  end

  def fetch_dep_info(dep_name) do
    with {:ok, dep} <- find_dep(dep_name),
         {:ok, dep_project_module} <- load_dep_project_module(dep),
         child_deps <- get_child_deps(dep) do
      {:ok, dep, dep_project_module, child_deps}
    else
      error -> error
    end
  end

  def find_dep(dep_name) do
    deps = Mix.Dep.cached()

    case Enum.find(deps, &(&1.app == dep_name)) do
      nil -> {:error, "Dependency #{dep_name} not found in the project."}
      dep -> {:ok, dep}
    end
  end

  def find_dep!(dep_name) do
    find_dep(dep_name)
    |> case do
      {:ok, dep} ->
        dep

      {:error, reason} ->
        raise "Dependency #{dep_name} not found in the project. Reason: #{reason}"
    end
  end

  def load_dep_project_module(dep) do
    dep_path = dep.opts[:dest]

    if dep_path && File.exists?(Path.join(dep_path, "mix.exs")) do
      Mix.Project.in_project(dep.app, dep_path, fn module ->
        {:ok, module}
      end)
    else
      {:error, :no_mixfile}
    end
  end

  def load_dep_project_module!(dep) do
    load_dep_project_module(dep)
    |> case do
      {:ok, m} -> m
      {:error, reason} -> raise "Cannot load project module: #{inspect(reason)}"
    end
  end

  defp get_child_deps(dep) do
    case dep.opts[:lock] do
      {:hex, _app, _version, _checksum, _mix, deps, _repo, _} ->
        deps
        |> Enum.take(5)
        |> Enum.map(fn {name, version, _opts} ->
          %{app: name, version: version}
        end)

      _ ->
        []
    end
  end

  def get_project_info(_dep, project_mod) do
    project_info = apply(project_mod, :project, [])

    %{
      description: project_info[:description],
      version: project_info[:version],
      source_url: project_info[:source_url]
      # changelog: read_file_if_exists(path, ["CHANGELOG.md", "README.md"])
    }
  end

  def read_file_if_exists(path, files) do
    files
    |> Enum.find_value(fn file ->
      file_path = Path.join(path, file)

      if File.exists?(file_path) do
        """
        ---- #{file} ----
        #{File.read!(file_path)}
        """
      else
        nil
      end
    end) || "No CHANGELOG.md or README.md found."
  end

  defp print_dep_info({:error, message}) do
    Mix.shell().error(message)
  end

  defp print_dep_info({:ok, dep, dep_project_mod, child_deps}) do
    prject_info = get_project_info(dep, dep_project_mod)

    Mix.shell().info("------------------------")
    Mix.shell().info("#{dep.app} #{prject_info[:version]}")
    Mix.shell().info("URL: #{prject_info[:source_url]}")
    Mix.shell().info("Desc: #{prject_info[:description]}")
    Mix.shell().info("Path: #{dep.opts[:dest] || "N/A"}")
    Mix.shell().info("------------------------")
    Mix.shell().info("Top Child Dependencies:")

    Enum.each(child_deps, fn child ->
      Mix.shell().info("- #{child.app} #{child.version}")
    end)
  end
end
