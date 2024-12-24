defmodule Mix.Tasks.Eh.Iex do
  @shortdoc "Gen ./.iex.exs"

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
      Mix.raise("Expected \"mix eh.iex\" without arguments, got: #{inspect(args)}")
    end

    # todo: hello-world => Hello World
    dirname = File.cwd!() |> Path.basename() |> String.capitalize()

    copy_template(tmpl_file("dot.iex.exs.eex"), ".iex.exs", [dirname: dirname], opts)
  end

  def tmpl_file(priv_file) do
    Path.join(:code.priv_dir(:ehelper), priv_file)
  end
end
