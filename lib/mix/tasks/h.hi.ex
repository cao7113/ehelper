defmodule Mix.Tasks.H.Hi do
  use Mix.Task

  @shortdoc "Hi mix task"

  @moduledoc """
  #{@shortdoc}.

  This is test mix-task from ehelper tasks.
  """

  def run(_) do
    vsn = Application.spec(:ehelper, :vsn)
    Mix.shell().info("Hi from ehelper-#{vsn}")
  end
end
