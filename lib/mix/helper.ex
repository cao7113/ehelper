defmodule Mix.Helper do
  def deps_paths(opts \\ []), do: Mix.Project.deps_paths(opts)
  def deps_apps, do: Mix.Project.deps_apps()
end
