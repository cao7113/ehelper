defmodule Mix.Tasks.H.Hc do
  @shortdoc "httpc get a resource"

  @moduledoc """
  #{@shortdoc}.

  use httpc client to get a resource
  """

  use Mix.Task
  alias ReqClient.Channel.Httpc

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
    {opts, argv} = OptionParser.parse_head!(args, strict: @switches, aliases: @aliases)
    url = List.first(argv) || @default_url

    Httpc.ensure_started!()
    shell = Mix.shell()
    shell.info("## Fetching URL: #{url}")

    case Httpc.get(url, opts) do
      {:ok, %{status: status, body: body}} ->
        body |> Ehelper.pp()
        shell.info("# Status: #{status}")
    end
  end
end
