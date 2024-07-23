defmodule Mix.Tasks.Eh.Gh.Ci do
  @shortdoc "Gen github actions workflows for ci"
  @workflows_dir ".github/workflows"

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
      Mix.raise("Expected \"mix eh.gh.ci\" without arguments, got: #{inspect(args)}")
    end

    File.mkdir_p!(@workflows_dir)

    copy_template(tmpl_file("github.workflows.ci.eex"), ".github/workflows/ci.yml", [], opts)
  end

  def tmpl_file(priv_file) do
    Path.join(:code.priv_dir(:ehelper), priv_file)
  end
end
