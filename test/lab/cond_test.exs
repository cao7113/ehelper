defmodule CondTest do
  use ExUnit.Case

  def max2(a, b) do
    cond do
      a >= b -> a
      true -> b
    end
  end

  def max2case(a, b) do
    case a >= b do
      true -> a
      false -> b
    end
  end

  test "max" do
    assert 2 == max2(1, 2)
    assert 2 == max2case(1, 2)
  end

  test "try with" do
    opts = %{width: 10}

    a =
      with {:ok, width} <- Map.fetch(opts, :width),
           {:ok, height} <- Map.fetch(opts, :height) do
        {:ok, width * height}
      end

    assert a == :error
  end

  test "try with ()" do
    with {:ok, a} <- {:ok, 3} do
      assert a == 3
    end
  end

  test "try with with else" do
    opts = %{width: 10}

    a =
      with {:ok, width} <- Map.fetch(opts, :width),
           {:ok, height} <- Map.fetch(opts, :height) do
        {:ok, width * height}
      else
        :error ->
          {:error, :wrong_data}
      end

    assert a == {:error, :wrong_data}
  end
end
