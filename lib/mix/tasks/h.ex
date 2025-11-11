defmodule Mix.Tasks.H do
  @shortdoc "List ehelper tasks"
  use Mix.Task

  @impl true
  @doc false
  def run(args) do
    case args do
      [] ->
        general()

      ["-h"] ->
        general()

      ["--help"] ->
        general()

      other ->
        # todo bugy now!
        {[], parsed_args, parsed_rest} =
          OptionParser.parse(other, switches: [])

        first = List.first(parsed_args)

        if first do
          [head | rest] = parsed_args
          real_task = "h.#{head}"

          parsed_rest = Enum.map(parsed_rest, fn {k, v} -> "#{k} #{v}" end)

          final_args = rest ++ parsed_rest
          Mix.shell().info("# Running task: mix #{real_task} #{Enum.join(final_args, " ")}")
          Mix.Task.run(real_task, final_args)
        else
          Mix.shell().error("Invalid arguments #{args |> inspect}, expected: mix h")
          general()
        end
    end
  end

  defp general() do
    Mix.shell().info("## Ehelper tasks\n")
    Mix.Tasks.Help.run(["--search", "h."])
  end
end
