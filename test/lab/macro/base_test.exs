defmodule A do
  defmacro m1 do
    1
  end
end

defmodule BaseTest do
  use ExUnit.Case

  test "macro work after require module" do
    require A
    assert 1 == A.m1()
  end

  test "macro also work after import module" do
    import A
    assert 1 == m1()
  end
end
