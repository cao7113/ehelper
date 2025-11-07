defmodule Mix.Tasks.H do
  @shortdoc "List ehelper tasks"
  use Mix.Task

  @impl true
  @doc false
  def run(args) do
    case args do
      [] -> general()
      _ -> Mix.raise("Invalid arguments, expected: mix eh")
    end
  end

  defp general() do
    # Application.ensure_all_started(:phoenix)
    # Mix.shell().info("Phoenix v#{Application.spec(:phoenix, :vsn)}")
    # Mix.shell().info("Peace of mind from prototype to production")
    # Mix.shell().info("\n## Options\n")
    # Mix.shell().info("-v, --version        # Prints Phoenix version\n")
    Mix.shell().info("## Ehelper tasks\n")
    Mix.Tasks.Help.run(["--search", "h."])
  end
end
