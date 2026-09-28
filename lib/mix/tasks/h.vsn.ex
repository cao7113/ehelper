defmodule Mix.Tasks.H.Vsn do
  @shortdoc "Get ehelper version"
  use Mix.Task

  @impl true
  def run(_args) do
    :ok = Application.load(:ehelper)

    Application.spec(:ehelper, :vsn)
    |> Kernel.to_string()
    |> Mix.shell().info()
  end
end
