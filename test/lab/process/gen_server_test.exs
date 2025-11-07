defmodule Process.GenServerTest do
  use ExUnit.Case

  defmodule G do
    use GenServer

    def start_link do
      GenServer.start_link(__MODULE__, [])
    end

    @impl GenServer
    def init([]) do
      # IO.puts("g started")
      {:ok, []}
    end
  end

  test "g crash" do
    {:ok, pid} = G.start_link()

    Process.flag(:trap_exit, true)
    assert Process.alive?(pid)

    Process.exit(pid, :kill)
    assert_receive {:EXIT, _pid, :killed}

    refute Process.alive?(pid)
  end
end
