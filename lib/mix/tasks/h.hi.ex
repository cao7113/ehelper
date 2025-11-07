defmodule Mix.Tasks.H.Hi do
  use Mix.Task

  @shortdoc "Hello mix task"

  def run(_) do
    vsn = Application.spec(:ehelper, :vsn)
    Mix.shell().info("Hi from ehelper-#{vsn}")
  end
end
