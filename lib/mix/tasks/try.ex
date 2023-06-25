defmodule Mix.Tasks.Try do
  @moduledoc """
  Try task
  """
  @shortdoc "try task"
  use Mix.Task

  @impl true
  def run(args) do
    args
    |> case do
      [] -> "No user args input."
      _ -> Enum.join(args, " ")
    end
    |> output

    output("## Mix Info")
    Mix.Project.build_path() |> output
    Mix.path_for(:archives) |> output
    Mix.path_for(:escripts) |> output
    Mix.target() |> output

    Mix.Project.config() |> IO.inspect(label: "mix project")
  end

  def output(info), do: Mix.shell().info(info |> to_string)
end
