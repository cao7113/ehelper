defmodule Mix.Tasks.H do
  @shortdoc "List ehelper tasks"

  @moduledoc """
  #{@shortdoc}.

  ## Example

  mix h
  mix h -h
  mix h deps
  mix h deps -s git
  """

  use Mix.Task

  @impl true
  @doc false
  def run(args) do
    case args do
      [] ->
        general()

      [a] when a in ["-h", "--help"] ->
        general()

      [sub_task | rest] = _others ->
        shell = Mix.shell()
        # shell.info("# other args: #{others |> inspect}")

        if String.starts_with?(sub_task, "-") do
          Mix.raise(
            "first-arg should be sub-task like `deps` to access h.deps but is #{sub_task}"
          )
        else
          real_task = "h.#{sub_task}"
          shell.info("# Running task: mix #{real_task} #{rest |> inspect}")
          Mix.Task.run(real_task, rest)
        end
    end
  end

  defp general() do
    Mix.shell().info("## Ehelper tasks (h.<subtask> or h subtask)\n")
    Mix.Tasks.Help.run(["--search", "h."])
  end
end
