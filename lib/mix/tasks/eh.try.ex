defmodule Mix.Tasks.Eh.Try do
  @moduledoc """
  Try task
  """
  @shortdoc "Just try"
  use Mix.Task

  @impl true
  def run(args) do
    args
    |> case do
      [] -> "No user args input."
      _ -> Enum.join(args, " ")
    end
    |> output

    output(
      "\n## Mix Info env: #{Mix.env()} target: #{Mix.target()} build-info: #{System.build_info() |> inspect}"
    )

    Mix.Project.build_path()
    |> IO.inspect(label: "build-path")

    Mix.path_for(:archives)
    |> IO.inspect(label: "archives path")
  end

  def output(info), do: Mix.shell().info(info |> to_string)
end
