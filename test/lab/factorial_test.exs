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
    factorial(n) |> Ehelper.pretty_number()
  end
end
