defmodule Mix.Tasks.H.Pkg do
  @shortdoc "List Hex package helper tasks"

  @moduledoc """
  #{@shortdoc}.

  Run `mix h.pkg` to list the package helper tasks, or pass a subtask name to
  invoke it directly.

  ## Examples

      mix h.pkg
      mix h.pkg info req
      mix h.pkg clone req _local
      mix h.pkg open req
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

      [subtask | rest] ->
        if String.starts_with?(subtask, "-") do
          Mix.raise("First argument should be a package subtask, got #{inspect(subtask)}")
        else
          Mix.Task.run("h.pkg.#{subtask}", rest)
        end
    end
  end

  defp general do
    Mix.shell().info("## Hex package tasks (h.pkg.<subtask> or h.pkg subtask)\n")
    Mix.Tasks.Help.run(["--search", "h.pkg"])
  end
end
