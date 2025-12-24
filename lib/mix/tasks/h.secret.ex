defmodule Mix.Tasks.H.Secret do
  use Mix.Task

  @shortdoc "Gen random secret"
  @min_bytes 20

  @moduledoc """
  #{@shortdoc}.

  Generate secret like: mix h.secret -b #{@min_bytes}
  """

  @switches [
    bytes: :integer
  ]

  @aliases [
    b: :bytes
  ]

  @impl Mix.Task
  def run(args) do
    {opts, args} = OptionParser.parse!(args, strict: @switches, aliases: @aliases)

    if args != [] do
      Mix.raise("Expected \"mix h.secret\" without arguments, got: #{inspect(args)}")
    end

    cnt = Keyword.get(opts, :bytes, @min_bytes)

    if cnt < @min_bytes do
      Mix.shell().error("#{cnt} less than min: #{@min_bytes}")
    end

    Mix.shell().info("# #{cnt} random bytes then url_encode64")

    # todo base58 encoding？
    Base.url_encode64(:crypto.strong_rand_bytes(cnt), padding: false)
    |> Mix.shell().info()
  end
end
