defmodule Ehelper.Str do
  @moduledoc """
  String helpers
  """

  @doc """
  valid utf8. Elixir has wonderful support for utf8: String.valid?/1 can detect valid and invalid utf8.
    String.valid?(<<0xEF, 0xB7, 0x90>>)
    true

    String.valid?("asd" <> <<0xFFFF::16>>)
    false
  """
  def utf8?(bin), do: String.valid?(bin)
end
