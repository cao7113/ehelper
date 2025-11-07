defmodule Ehelper.Factorial do
  @moduledoc """
  Factorial functions
  """

  def factorial(1), do: 1

  def factorial(n) when n > 0 do
    n * factorial(n - 1)
  end

  def factorial(n) do
    raise "unexpected #{n}"
  end

  def pretty_factorial(n) do
    factorial(n) |> pretty_number()
  end

  def pretty_number(n) do
    n
    |> to_string
    |> String.to_charlist()
    |> Enum.chunk_every(3)
    |> Enum.map(&to_string/1)
    |> Enum.join(", ")
  end
end
