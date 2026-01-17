defmodule Mix.Tasks.H.Chrome.Mv3 do
  @shortdoc "Gen Chrome Extension V3 manifest.json"

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
      Mix.raise("Expected \"mix h.chrome.mv3\" without arguments, got: #{inspect(args)}")
    end

    dirname = File.cwd!() |> Path.basename() |> String.capitalize()

    copy_template(
      Mix.Template.get_priv_file("chrome-extension-manifest.json.eex"),
      "manifest.json",
      [dirname: dirname],
      opts
    )
  end
end
