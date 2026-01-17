defmodule Mix.Tasks.H.Task do
  @shortdoc "Generate a new Mix task"
  use Mix.Task
  import Mix.Generator

  @swithes [
    dry: :boolean
  ]
  @aliases [
    d: :dry
  ]
  @impl true
  def run(args) do
    shell = Mix.shell()
    {opts, args} = OptionParser.parse_head!(args, strict: @swithes, aliases: @aliases)

    task_name =
      case args do
        [name | _] -> name
        [] -> Mix.raise("Expected task name, got: #{inspect(args)}")
      end

    task_module = Mix.Template.task_to_module_name(task_name)

    assigns = [
      task_module: task_module,
      task_name: task_name,
      shortdoc: "TODO: shortdoc for #{task_name}"
    ]

    dry = Keyword.get(opts, :dry)

    tmpl_file = Mix.Template.get_priv_file("mix.task.eex")
    task_file = "lib/mix/tasks/#{task_name}.ex"

    if dry do
      shell.info("# The following file would be generated: #{task_file}\n")

      EEx.eval_file(tmpl_file, assigns: assigns)
      |> shell.info()
    else
      copy_template(tmpl_file, task_file, assigns, opts)
    end
  end
end
