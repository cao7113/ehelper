defmodule Mix.Tasks.H.Me do
  @shortdoc "Generate README.md file"

  @moduledoc """
  #{@shortdoc}.

  ## Options
  - `--force` or `-f`: overwrite the file if it already exists
  - `--quiet` or `-q`: suppress output messages
  - `--dry` or `-d`: preview the content without creating the file
  """

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
      Mix.raise("Expected \"mix h.readme\" without arguments, got: #{inspect(args)}")
    end

    # todo: hello-world => Hello World
    dirname = File.cwd!() |> Path.basename() |> String.capitalize()

    content =
      EEx.eval_file(Mix.Template.get_priv_file("README.md.eex"), assigns: [dirname: dirname])

    target_file = "README.md"

    if opts[:dry] do
      shell = Mix.shell()
      shell.info("# will create target file: #{target_file} contents as follows")
      shell.info(content)
    else
      opts = Keyword.take(opts, [:force, :quiet])
      create_file(target_file, content, opts)
    end
  end
end
