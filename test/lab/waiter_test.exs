defmodule WaiterTest do
  use ExUnit.Case

  def do_md5(times \\ 100_000) do
    1..times
    |> Enum.each(fn i ->
      :erlang.md5("#{i}")
      |> Base.encode16(case: :lower)
    end)
  end

  test "async and await" do
    p1 =
      Task.async(fn ->
        do_md5()
        2
      end)

    assert 3 == 1 + Task.await(p1)
  end

  test "wait by msg" do
    parent = self()

    Task.start_link(fn ->
      do_md5()
      send(parent, :hashed)
    end)

    # |> IO.inspect(label: "start task")

    result =
      receive do
        :hashed -> :ok
      after
        5_000 -> :timeout
      end

    assert result == :ok
  end
end
