defmodule Mix.Tasks.H.Taskfile do
  @shortdoc "Gen Taskfile.yml"

  use Mix.Task
  import Mix.Generator

  @switches [
    force: :boolean,
    quiet: :boolean,
    dry: :boolean
  ]

  @aliases [
    f: :force,
    q: :quiet,
    d: :dry
  ]

  @impl true
  def run(args) do
    {opts, args} = OptionParser.parse!(args, strict: @switches, aliases: @aliases)

    if args != [] do
      Mix.raise("Expected \"mix h.taskfile\" without arguments, got: #{inspect(args)}")
    end

    assigns = []
    dry = Keyword.get(opts, :dry)

    tmpl_file = Mix.Template.get_priv_file("Taskfile.yml.eex")

    if dry do
      EEx.eval_file(tmpl_file, assigns: assigns)
      |> Mix.shell().info()
    else
      copy_template(tmpl_file, "Taskfile.yml", assigns, opts)
    end
  end
end
