defmodule Mix.Tasks.H.Dep do
  @shortdoc "Show dependency info or list dependency tasks"

  @moduledoc """
  #{@shortdoc}.

  Pass a dependency name to show its info; this is shorthand for
  `mix h.dep.info`. Run without arguments to list available tasks.

  ## Examples

      mix h.dep
      mix h.dep plug
      mix h.dep spec plug
  """

  use Mix.Task

  @impl true
  @doc false
  def run(args) do
    case args do
      [] ->
        general()

      [argument] when argument in ["-h", "--help"] ->
        general()

      ["info" | rest] ->
        Mix.Task.run("h.dep.info", rest)

      ["spec" | rest] ->
        Mix.Task.run("h.dep.spec", rest)

      dep_args ->
        Mix.Task.run("h.dep.info", dep_args)
    end
  end

  defp general do
    Mix.shell().info("## Dependency tasks (h.dep.<subtask> or h.dep subtask)\n")
    Mix.Tasks.Help.run(["--search", "h.dep"])
  end
end
