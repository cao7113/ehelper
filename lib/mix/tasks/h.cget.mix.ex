defmodule Mix.Tasks.H.Cget.Mix do
  @shortdoc "httpc get a resource"

  @moduledoc """
  #{@shortdoc}.

  use Mix.Utils to get a resource, Good!!!
  """

  use Mix.Task

  @default_url "https://slink.fly.dev/api/ping"

  @switches [
    debug: :boolean,
    method: :string
  ]

  @aliases [
    m: :method,
    d: :debug
  ]

  @impl true
  def run(args) do
    {_opts, argv} = OptionParser.parse_head!(args, strict: @switches, aliases: @aliases)
    url = List.first(argv) || @default_url
    shell = Mix.shell()
    shell.info("Fetching URL: #{url}")

    Mix.Utils.read_path(url)
    |> dbg
  end
end
