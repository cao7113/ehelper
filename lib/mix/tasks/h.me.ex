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
    shell = Mix.shell()
    {opts, args} = OptionParser.parse!(args, strict: @switches, aliases: @aliases)

    if args != [] do
      Mix.raise("Expected \"mix h.readme\" without arguments, got: #{inspect(args)}")
    end

    # todo: hello-world => Hello World
    dirname = File.cwd!() |> Path.basename() |> String.capitalize()
    assigns = [dirname: dirname]
    tmpl_file = Mix.Template.get_priv_file("README.md.eex")

    target_file = "README.md"
    dry? = Keyword.get(opts, :dry, false)

    if dry? do
      shell.info("# The following file would be generated: #{target_file}\n")

      EEx.eval_file(tmpl_file, assigns: assigns)
      |> shell.info()
    else
      opts = Keyword.take(opts, [:force, :quiet])
      Mix.Generator.copy_template(tmpl_file, target_file, assigns, opts)
    end
  end
end
