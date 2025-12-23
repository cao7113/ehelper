defmodule Mix.Tasks.H.Gh.Repo do
  @shortdoc "Show github repo info"

  @moduledoc """
  #{@shortdoc}.

  Get github repo info
  """

  use Mix.Task
  alias Ehelper.Httpc

  @default_url "https://api.github.com/repos/elixir-lang/elixir"

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

    shell.info("Fetching URL: #{url}")

    case Httpc.get(url, opts) do
      %{status: status, body: body, taken_ms: taken_ms} ->
        shell.info("Status: #{status} taken_ms: #{taken_ms}")
        body |> IO.inspect()
    end
  end
end
