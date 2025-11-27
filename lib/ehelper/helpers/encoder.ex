defmodule Ehelper.Encoder do
  @moduledoc """
  Encoding and decoding helpers

  bianry integer
  # 0b0100 #=> 4

  #iex>  123 |> dbg(base: :binary)
  #iex>  # 123 #=> 0b1111011
  """

  # 258 |> :binary.encode_unsigned() |> :crypto.bytes_to_integer
  def uint2bytes(num) do
    :binary.encode_unsigned(num)
  end

  def bytes2uint(bytes) do
    bytes |> :crypto.bytes_to_integer()
  end
end
