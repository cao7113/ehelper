defmodule Mix.Tasks.H.Code.Hi do
  @shortdoc "Show ehelper code path snippet"
  use Mix.Task

  # :force - forces copying without a shell prompt
  # :quiet - does not log command output
  # :format_elixir (since v1.18.0) - if true, apply formatter to the generated file

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
    {opts, args} = OptionParser.parse_head!(args, strict: @switches, aliases: @aliases)

    tmpl_file = Mix.Template.get_priv_file("ehi.exs.eex")
    target_file = List.first(args) || "ehi.exs"

    shell = Mix.shell()

    if opts[:dry] do
      File.read!(tmpl_file) |> IO.puts()
    else
      if Mix.Generator.copy_template(tmpl_file, target_file, [], opts) do
        shell.info("# Write file to #{target_file}")
        File.chmod!(target_file, 0o755)
      end
    end
  end
end
