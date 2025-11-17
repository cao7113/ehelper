defmodule Mix.Tasks.H.Gen.Secret do
  @shortdoc "Generates random secret with specified length"
  @default_length 64
  @min_length 15

  @moduledoc """
  #{@shortdoc}.

      $ mix h.gen.secret --length #{@default_length}

  By default, mix h.gen.secret generates a key `64` characters long.

  The minimum value for `length` is `#{@min_length}` unless force request!

  ## Links(based on Plug.Crypto)
    - https://hexdocs.pm/plug_crypto/Plug.Crypto.html
    - https://github.com/phoenixframework/phoenix/blob/main/lib/mix/tasks/phx.gen.secret.ex
    - https://github.com/phoenixframework/phoenix/blob/main/lib/phoenix/token.ex
  """

  use Mix.Task

  @switches [length: :integer]
  @aliases [l: :length]

  def run(args) do
    {opts, _args} = OptionParser.parse_head!(args, strict: @switches, aliases: @aliases)
    length = Keyword.get(opts, :length, @default_length)

    random_string(length)
    |> Mix.shell().info()
  end

  defp random_string(length) when length >= @min_length do
    length
    |> :crypto.strong_rand_bytes()
    # |> Base.encode64(padding: false)
    |> Base.url_encode64(padding: false)
    |> binary_part(0, length)
  end

  defp random_string(_), do: Mix.raise("The secret should be at least 12 bytes long")
end
