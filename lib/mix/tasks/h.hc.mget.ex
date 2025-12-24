defmodule Mix.Tasks.H.Hc.Mget do
  @shortdoc "Get a resource with Mix.Utils.read_path built on httpc"

  @moduledoc """
  #{@shortdoc}.

  Mix.Utils.read_path is great and support proxy and timeout

  - https://github.com/elixir-lang/elixir/blob/main/lib/mix/lib/mix/utils.ex#L733

  ## Examples

    mix h.hc.mget https://slink.fly.dev/api/ping
    mix h.hc.mget https://raw.githubusercontent.com/cao7113/req_client/refs/heads/main/lib/req_client/ref/httpc.ex
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
    shell.info("## Fetching URL: #{url} at #{DateTime.utc_now()}")

    with {:ok, body} <- Mix.Utils.read_path(url) do
      IO.puts(body)
    end
  end
end
