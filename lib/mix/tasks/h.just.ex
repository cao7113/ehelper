defmodule Mix.Tasks.H.Just do
  @shortdoc "Gen Justfile as https://just.systems/man/en/"

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
      Mix.raise("Expected \"mix h.just\" without arguments, got: #{inspect(args)}")
    end

    copy_template(tmpl_file("Justfile.eex"), "Justfile", [], opts)
  end

  def tmpl_file(priv_file) do
    Path.join(:code.priv_dir(:ehelper), priv_file)
  end
end
