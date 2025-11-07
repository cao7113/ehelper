defmodule BasicTest do
  use ExUnit.Case

  # control flows
  test "try case when" do
    result =
      case {1, 2, 3} do
        {1, x, 3} when x > 1 ->
          "matched"

        _ ->
          "not matched"
      end

    assert result == "matched"
  end

  test "" do
    "hit me"
    |> case do
      "hit" <> _ ->
        # should hit this
        assert 1 == 1

      otherwise ->
        assert otherwise == "never occur"
    end
  end
end
