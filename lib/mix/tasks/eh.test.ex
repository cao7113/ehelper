defmodule Mix.Tasks.Eh.Test do
  @shortdoc "Just test task"
  use Mix.Task

  @impl true
  def run(_args) do
    # args
    # |> case do
    #   [] -> "No user args input."
    #   _ -> Enum.join(args, " ")
    # end
    # |> output

    output(
      "\n## Mix Info env: #{Mix.env()}, target: #{Mix.target()} \nbuild-info: #{System.build_info() |> inspect}"
    )

    Mix.Project.build_path()
    |> IO.inspect(label: "build-path")

    Mix.path_for(:archives)
    |> IO.inspect(label: "archives path")
  end

  def output(info), do: Mix.shell().info(info |> to_string)
end
