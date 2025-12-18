defmodule Mix.Tasks.H.Test do
  @shortdoc "Just test task"
  use Mix.Task

  @impl true
  def run(_args) do
    shell = Mix.shell()
    vsn = Application.spec(:ehelper, :vsn)

    ~s"""
    ## Test task from ehelper-#{vsn}

    Mix env: #{Mix.env()}, target: #{Mix.target()}
    """
    |> shell.info()

    System.build_info()
    |> IO.inspect(label: "build-info")

    Mix.Project.build_path()
    |> IO.inspect(label: "build-path")

    Mix.path_for(:archives)
    |> IO.inspect(label: "archives path")
  end
end
