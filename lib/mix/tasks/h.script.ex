defmodule Mix.Tasks.H.Script do
  @shortdoc "Generate a runnable Elixir script file"
  use Mix.Task

  @switches [dry: :boolean, verbose: :boolean, quiet: :boolean, force: :boolean]
  @aliases [d: :dry, v: :verbose, q: :quiet, f: :force]

  @impl true
  def run(args) do
    shell = Mix.shell()
    {opts, argv} = OptionParser.parse_head!(args, strict: @switches, aliases: @aliases)
    script_file = List.first(argv) || "run/hi.exs"

    script_file =
      if !String.ends_with?(script_file, ".exs") do
        script_file <> ".exs"
      else
        script_file
      end

    tmpl_file = Mix.Template.get_priv_file("script.exs.eex")
    assigns = [script_file: script_file]
    dry? = Keyword.get(opts, :dry)

    if dry? do
      shell.info("# The following file would be generated: #{script_file}\n")

      EEx.eval_file(tmpl_file, assigns: assigns)
      |> shell.info()
    else
      File.chmod(script_file, 0o755)
      opts = Keyword.put(opts, :format_elixir, true)
      Mix.Generator.copy_template(tmpl_file, script_file, assigns, opts)
    end
  end
end
