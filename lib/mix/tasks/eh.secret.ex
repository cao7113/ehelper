defmodule Mix.Tasks.Eh.Secret do
  use Mix.Task

  @shortdoc "Gen random secret"

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
      Mix.raise("Expected \"mix eh.secret\" without arguments, got: #{inspect(args)}")
    end

    min = 20
    cnt = opts[:bytes] || Enum.random(min..80)

    if cnt < min do
      Mix.shell().error("#{cnt} less than min: #{min}")
    end

    Mix.shell().info("# #{cnt} random bytes then encode64")

    # todo base58 encoding？
    Base.url_encode64(:crypto.strong_rand_bytes(cnt))
    |> Mix.shell().info()
  end
end
