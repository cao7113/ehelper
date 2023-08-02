defmodule Mix.Tasks.G.Taskfile do
  @shortdoc "gen Taskfile.yml"
  use Mix.Task

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
      Mix.raise("Expected \"mix eh.gen.taskfile\" without arguments, got: #{inspect(args)}")
    end

    Mix.Generator.copy_template(tmpl_file("Taskfile.yml.eex"), "Taskfile.yml", [], opts)
  end

  def tmpl_file(priv_file) do
    Path.join(:code.priv_dir(:ehelper), priv_file)
  end
end
