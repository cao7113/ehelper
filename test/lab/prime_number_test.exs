defmodule PrimeNumber do
  def is_prime(n) when n in [2, 3], do: true

  def is_prime(n) when is_integer(n) and n > 3 do
    r = :math.sqrt(n) |> floor()

    2..r
    |> Enum.all?(fn d ->
      rem(n, d) != 0
    end)
  end

  def is_prime(_n), do: false

  def prime_factors_for(n) when n in 0..3 do
    [n]
  end

  def prime_factors_for(n) when is_integer(n) and n > 3 do
    r = :math.sqrt(n) |> floor()

    2..r
    |> Enum.find(fn d ->
      rem(n, d) == 0
    end)
    |> case do
      nil ->
        # when not found divisor
        [n]

      d ->
        # first divisor should be a prime
        r = div(n, d)
        # TODO: refactor to tail call
        [d] ++ prime_factors_for(r)
    end
  end

  def rand_number(bytes \\ 8) do
    bytes
    |> :crypto.strong_rand_bytes()
    |> :crypto.bytes_to_integer()
  end

  def nth_prime(_n) do
    # TODO:
  end
end

defmodule PrimeNumberTest do
  use ExUnit.Case
  import PrimeNumber

  test "is_prime" do
    assert is_prime(2)
    assert is_prime(3)

    refute is_prime(4)
    refute is_prime(234)
  end

  describe "prime_factors_for" do
    test "base" do
      assert [1] == prime_factors_for(1)
      assert [2] == prime_factors_for(2)
      assert [2, 3] == prime_factors_for(6)
      assert [7] == prime_factors_for(7)
      assert [2, 2, 2] == prime_factors_for(8)
    end

    @tag :manual
    test "big number" do
      items = [2, 2, 3, 3, 3, 19, 19, 461, 10463, 16493]

      items
      |> Enum.reduce(fn e, a -> e * a end)
      |> prime_factors_for()
      |> assert(items)

      :crypto.strong_rand_bytes(8)
      |> :crypto.bytes_to_integer()
      |> IO.inspect(label: "rand-number")
      |> prime_factors_for()
      |> IO.inspect(label: "factors")
    end
  end
end
