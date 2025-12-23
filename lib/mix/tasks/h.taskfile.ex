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

    # copy_template(tmpl_file("Taskfile.yml.eex"), "Taskfile.yml", [], opts)
    assigns = []
    dry = Keyword.get(opts, :dry)

    tmpl_file = Mix.Template.get_priv_file("Taskfile.yml.eex")

    if dry do
      EEx.eval_file(tmpl_file, assigns: assigns)
      |> Mix.shell().info()
    else
      opts = [format_elixir: true] |> Keyword.merge(opts)
      copy_template(tmpl_file, "Taskfile.yml", assigns, opts)
    end
  end

  # def tmpl_file(priv_file) do
  #   Path.join(:code.priv_dir(:ehelper), priv_file)
  # end
end
