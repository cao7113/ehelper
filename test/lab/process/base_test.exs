defmodule Process.BaseTest do
  use ExUnit.Case
  @moduletag :manual

  defmodule Listener do
    def start do
      spawn(__MODULE__, :listen, [self()])
    end

    def listen(from) do
      receive do
        :hello ->
          send(from, :world)
      end

      listen(from)
    end
  end

  defmodule Store do
    def start do
      spawn(__MODULE__, :loop, [%{}])
    end

    def loop(state) do
      receive do
        {:stop, pid} ->
          send(pid, "Shutting down")

        {:put, key, value} ->
          new_state = Map.put(state, key, value)
          loop(new_state)

        {:get, key, pid} ->
          value = Map.fetch(state, key)
          send(pid, value)
          loop(state)

        {:get_all, pid} ->
          send(pid, state)
          loop(state)

        _ ->
          loop(state)
      end
    end
  end

  describe "crashing" do
    test "process crash not affect other process" do
      spawn(fn ->
        raise "process crashed"
      end)

      Process.sleep(10)
      assert true
    end

    test "trap exit on linked-process crash" do
      spawn_link(fn ->
        raise "subprocess crashed"
      end)

      # should trap exit on this process
      Process.flag(:trap_exit, true)

      assert_receive {:EXIT, _from_pid, reason}

      {%RuntimeError{
         message: "subprocess crashed"
       }, _stacks} = reason
    end

    test "link and unlink" do
      caller = self()

      pid =
        spawn_link(fn ->
          receive do
            :crash -> exit(:boom)
          end
        end)

      {:links, links} = Process.info(caller, :links)
      assert Enum.member?(links, pid)
      Process.unlink(pid)
      send(pid, :crash)
      {:links, links} = Process.info(caller, :links)
      assert links == []
    end

    test "monitor process" do
      spawn_monitor(fn ->
        raise "subprocess crashed"
      end)

      assert_receive {:DOWN, _ref, :process, _from_pid, reason}

      {%RuntimeError{
         message: "subprocess crashed"
       }, _stacks} = reason
    end

    test "monitor" do
      pid1 =
        spawn(fn ->
          receive do
            :add -> IO.puts(1 + 2)
          end
        end)

      ref1 = Process.monitor(pid1)

      pid2 =
        spawn(fn ->
          receive do
            :multi -> IO.puts(2 * 3)
          end
        end)

      ref2 = Process.monitor(pid2)

      {:monitors, ps} =
        Process.info(self(), :monitors)
        |> IO.inspect(label: "monitors")

      assert length(ps) == 2

      {:monitored_by, m} = Process.info(self(), :monitored_by)
      m |> IO.inspect(label: "monitored-by")

      send(pid1, :add)
      assert_receive {:DOWN, ^ref1, :process, ^pid1, :normal}

      Process.info(self(), :monitors)
      |> IO.inspect(label: "last monitors after one exit normally")

      Process.demonitor(ref2)

      Process.info(self(), :monitors)
      |> IO.inspect(label: "monitors after demonitor")
    end
  end

  describe "message" do
    test "mismatch not affect next matched msg" do
      caller = self()
      pid = spawn(Listener, :listen, [caller])
      send(pid, :unknown)
      send(pid, :hello)
      assert_receive :world
    end

    test "timeout even receive mismatched message" do
      caller = self()
      timeout = 5

      spawn(fn ->
        receive do
          :ping ->
            send(caller, :pong)
        after
          timeout ->
            send(caller, :timeout)
        end
      end)
      |> send(:missing)

      assert_receive :timeout
    end
  end
end
