defmodule Mix.Tasks.H.Scm do
  use Mix.Task

  @shortdoc "mix SCM"

  @moduledoc """
  #{@shortdoc}.

  """

  def run(_) do
    info = Mix.SCM.available()
    Mix.shell().info("available SCMs: #{inspect(info)}")
  end
end
