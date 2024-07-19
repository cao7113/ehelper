defmodule Mix.Tasks.Eh.Fly do
  @shortdoc "Gen fly.toml to deploy app to https://fly.io"

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
      Mix.raise("Expected \"mix eh.fly\" without arguments, got: #{inspect(args)}")
    end

    dirname = File.cwd!() |> Path.basename() |> String.capitalize()

    copy_template(tmpl_file("fly.toml.eex"), "fly.toml", [dirname: dirname], opts)
  end

  def tmpl_file(priv_file) do
    Path.join(:code.priv_dir(:ehelper), priv_file)
  end
end
