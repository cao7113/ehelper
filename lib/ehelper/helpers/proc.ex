defmodule Ehelper.Proc do
  @moduledoc """
  Erlang Process Helpers

  - https://hexdocs.pm/elixir/Process.html
  - https://hexdocs.pm/elixir/GenServer.html#module-debugging-with-the-sys-module
  """

  @doc """
  Get process info
  iex> process_info self() # from IEx.Helpers better?
  """
  def info(name_or_pid) do
    name_or_pid
    |> pid()
    |> Process.info()
  end

  @doc """
  Get process current state
  Debuging with :sys.xxx

  - https://kevgathuku.dev/get-state-from-a-genserver-process-in-elixir
  - https://hexdocs.pm/elixir/GenServer.html#module-debugging-with-the-sys-module
  """
  def state(name_or_pid, opts \\ []) do
    name_or_pid
    |> pid()
    |> case do
      nil ->
        :not_found_pid

      p ->
        timeout = Keyword.get(opts, :timeout, 200)
        :sys.get_state(p, timeout)
    end
  end

  def status(name_or_pid) do
    name_or_pid
    |> pid()
    |> case do
      nil -> :not_found_pid
      p -> :sys.get_status(p)
    end
  end

  defdelegate alive?(pid), to: Process
  defdelegate whereis(name), to: Process

  @doc """
  Get process id
  iex also support: pid(0, 21, 32)

  GenServer.whereis(aGenServer)
  """
  def pid(pid) when is_pid(pid), do: pid
  def pid(name) when is_atom(name), do: Process.whereis(name)
  def pid(n) when is_integer(n), do: pid("#PID<0.#{n}.0>")
  def pid("#PID<" <> pstr), do: pstr |> String.trim_trailing(">") |> pid()
  def pid("PID<" <> pstr), do: pstr |> String.trim_trailing(">") |> pid()
  def pid("<" <> pstr), do: pstr |> String.trim_trailing(">") |> pid()

  # https://github.com/elixir-lang/elixir/blob/v1.14.0/lib/iex/lib/iex/helpers.ex#L1248
  # iex> pid("0.664.0") # => #PID<0.664.0>
  def pid(string) when is_binary(string) do
    :erlang.list_to_pid(~c"<#{string}>")
  end

  ## Debugging
  # :erlang.process_info(pid, :message_queue_len)
  # - https://www.erlang.org/doc/apps/erts/erlang.html#process_info/2

  def dict(pid) do
    pid = pid(pid)

    case Process.info(pid, :dictionary) do
      {:dictionary, dict} -> dict
      _ -> []
    end
  end

  def msgbox(pid), do: message_queue(pid)
  def mailbox(pid), do: message_queue(pid)

  def message_queue(pid) when is_pid(pid) do
    if alive?(pid) do
      [
        len: Process.info(pid, :message_queue_len) |> elem(1),
        queue: Process.info(pid, :messages) |> elem(1),
        data: Process.info(pid, :message_queue_data) |> elem(1)
      ]
    else
      raise "Process #{inspect(pid)} is not alive"
    end
  end

  def storage(pid) do
    [
      memory: Process.info(pid, :memory) |> elem(1),
      total_heap_size: Process.info(pid, :total_heap_size) |> elem(1),
      heap_size: Process.info(pid, :heap_size) |> elem(1),
      stack_size: Process.info(pid, :stack_size) |> elem(1),
      garbage_collection: Process.info(pid, :garbage_collection) |> elem(1)
    ]
  end

  def priority(pid), do: Process.info(pid, :priority) |> elem(1)
  def reductions(pid), do: Process.info(pid, :reductions) |> elem(1)

  def ancesstors(pid), do: dict(pid)[:"$ancestors"]
  def callers(pid), do: dict(pid)[:"$callers"]

  def pids(pid) do
    [
      self: pid,
      parent: Process.info(pid, :parent) |> elem(1),
      links: Process.info(pid, :links) |> elem(1),
      registered_name: Process.info(pid, :registered_name) |> elem(1),
      group_leader: Process.info(pid, :group_leader) |> elem(1),
      monitors: Process.info(pid, :monitors) |> elem(1) |> Enum.uniq(),
      monitored_by: Process.info(pid, :monitored_by) |> elem(1)
    ]
  end

  @doc """
  :sys.statistics(pid, true) # turn on collecting process statistics
  :sys.trace(pid, true) # turn on event printing
  """
  def stats(pid, flag \\ true) when is_pid(pid), do: :sys.statistics(pid, flag)
  def trace(pid, flag \\ true) when is_pid(pid), do: :sys.trace(pid, flag)

  def debug(pid) when is_pid(pid) do
    stats(pid, true)
    trace(pid, true)
    :sys.log(pid, true)
  end

  # :sys.no_debug(pid) # turn off all debug handlers
  def no_debug(pid) when is_pid(pid), do: :sys.no_debug(pid)

  def info_spec(pid, spec), do: Process.info(pid, spec)

  def info_keys(pid \\ self()) do
    pid
    |> Process.info()
    |> Keyword.keys()
    |> Enum.sort()

    # https://www.erlang.org/doc/apps/erts/erlang.html#t:process_info_item/0
    # https://www.erlang.org/doc/apps/erts/erlang.html#process_info/2
    # process_info_item()
    # -type process_info_item() ::
    #           async_dist | backtrace | binary | catchlevel | current_function | current_location |
    #           current_stacktrace | dictionary |
    #           {dictionary, Key :: term()} |
    #           error_handler | garbage_collection | garbage_collection_info | group_leader | heap_size |
    #           initial_call | links | label | last_calls | memory | message_queue_len | messages |
    #           min_heap_size | min_bin_vheap_size | monitored_by | monitors | message_queue_data | parent |
    #           priority | priority_messages | reductions | registered_name | sequential_trace_token |
    #           stack_size | status | suspending | total_heap_size | trace | trap_exit.
    # [
    #   :current_function,
    #   :dictionary,
    #   :error_handler,
    #   :garbage_collection,
    #   :group_leader,
    #   :heap_size,
    #   :initial_call,
    #   :links,
    #   :message_queue_len,
    #   :priority,
    #   :reductions,
    #   :stack_size,
    #   :status,
    #   :suspending,
    #   :total_heap_size,
    #   :trap_exit
    # ]
  end

  ## Control

  def ls(), do: Process.list()
  def suspend(pid) when is_pid(pid), do: :sys.suspend(pid)
  def resume(pid) when is_pid(pid), do: :sys.resume(pid)
  def stop_async(pid, reason \\ :normal) when is_pid(pid), do: :sys.terminate(pid, reason)
  def kill(pid, reason \\ :kill) when is_pid(pid), do: Process.exit(pid, reason)

  @waiter_name :waiter
  def waiter(opts \\ []) do
    name = Keyword.get(opts, :name, @waiter_name)

    Process.whereis(name)
    |> case do
      nil ->
        nil

      pid ->
        if opts[:force] do
          Process.unregister(name)
          Process.exit(pid, :normal)
          nil
        else
          pid
        end
    end
    |> case do
      nil ->
        pid =
          spawn_link(fn ->
            # https://hexdocs.pm/elixir/Kernel.SpecialForms.html#receive/1
            receive do
              :flush ->
                flush_mailbox()
            after
              # this is default
              :infinity ->
                :forever_here
            end
          end)

        Process.register(pid, name)
        pid

      pid ->
        pid
    end
  end

  defp flush_mailbox do
    receive do
      _ -> flush_mailbox()
    end
  end

  def sleep_forever, do: Process.sleep(:infinity)

  ## Supervisor childs

  @doc """
  Get child pid of a supervisor
  """
  def child_pid(sup, child_id)
      when is_atom(sup) and (is_atom(child_id) or is_binary(child_id)) do
    sup
    |> Supervisor.which_children()
    |> Enum.find(fn {id, _pid, _tp, _mods} ->
      id == child_id
    end)
    |> case do
      nil -> {:error, :not_found_child}
      {_id, pid, _tp, _mods} -> pid
    end
  end

  def restart_child(sup, child_id) do
    with :ok <- Supervisor.terminate_child(sup, child_id) do
      Supervisor.restart_child(sup, child_id)
    end
  end

  def remove_child(sup, child_id) do
    with :ok <- Supervisor.terminate_child(sup, child_id) do
      Supervisor.delete_child(sup, child_id)
    end
  end

  ## System

  @doc """
  Returns the operating system PID for the current Erlang runtime system instance.
  """
  def system_pid(), do: System.pid() |> String.to_integer()
end
