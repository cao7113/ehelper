defmodule Mix.Tasks.H.Taskfile.Mix do
  @shortdoc "Gen Taskfile.yml for mix project"
  use Mix.Task

  import Mix.Generator

  @switches [
    force: :boolean,
    quiet: :boolean
  ]

  @aliases [
    f: :force,
    q: :quiet
  ]

  @impl true
  def run(args) do
    {opts, args} = OptionParser.parse!(args, strict: @switches, aliases: @aliases)

    if args != [] do
      Mix.raise("Expected \"mix h.taskfile.mix\" without arguments, got: #{inspect(args)}")
    end

    copy_template(Mix.Template.get_priv_file("Taskfile.yml.mix.eex"), "Taskfile.yml", [], opts)
  end
end
