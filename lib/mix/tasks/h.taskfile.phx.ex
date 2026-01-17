defmodule Mix.Tasks.H.Taskfile.Phx do
  @shortdoc "Gen Taskfile.yml for phx project"
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
      Mix.raise("Expected \"mix h.taskfile.phx\" without arguments, got: #{inspect(args)}")
    end

    copy_template(Mix.Template.get_priv_file("Taskfile.yml.phx.eex"), "Taskfile.yml", [], opts)
  end
end
