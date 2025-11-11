defmodule Ehelper.Pinger do
  @moduledoc """
  Try GenServer

  - https://hexdocs.pm/elixir/GenServer.html#content
  """

  use GenServer

  ## User API

  def pid, do: Process.whereis(__MODULE__)

  def ping(pid \\ __MODULE__) do
    GenServer.call(pid, :ping)
  end

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  ## GenServer Callbacks

  @impl true
  def init(init_arg) do
    {:ok, init_arg}
  end

  @impl true
  def handle_call(:ping, _from, state) do
    {:reply, :pong, state}
  end

  @impl true
  def handle_cast(:push, state) do
    {:noreply, state}
  end
end
