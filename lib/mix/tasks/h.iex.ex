defmodule Mix.Tasks.H.Iex do
  @shortdoc "Gen ./.iex.exs"

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
      Mix.raise("Expected \"mix h.iex\" without arguments, got: #{inspect(args)}")
    end

    {dry, opts} = Keyword.pop(opts, :dry)

    # todo: hello-world => Hello World
    dirname = File.cwd!() |> Path.basename() |> String.capitalize()
    assigns = [dirname: dirname]
    tmpl_file = Mix.Template.get_priv_file("dot.iex.exs.eex")

    if dry do
      EEx.eval_file(tmpl_file, assigns: assigns)
      |> Mix.shell().info()
    else
      opts = [format_elixir: true] |> Keyword.merge(opts)
      copy_template(tmpl_file, ".iex.exs", assigns, opts)
    end
  end
end
