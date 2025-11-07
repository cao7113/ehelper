defmodule Ehelper.Iex do
  def iex_config do
    IEx.configuration()
  end

  def blanks(n \\ 20) do
    1..n
    |> Enum.each(fn _ ->
      IO.puts("")
    end)
  end
end

# import Ehelper.Iex
