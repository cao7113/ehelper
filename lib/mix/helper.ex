defmodule Mix.Helper do
  # todo read more Mix.Project and used in h tasks

  def deps_paths(opts \\ []), do: Mix.Project.deps_paths(opts)
  def deps_apps, do: Mix.Project.deps_apps()
end
