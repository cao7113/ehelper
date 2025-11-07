defmodule Ehelper.Ag do
  @moduledoc """
  Agent helper

  In fact Agent is very simple GenServer based process with some handy state get-and-update utilities!
  """

  use Agent

  def start!(initial_value \\ 0) do
    {:ok, pid} = Agent.start_link(fn -> initial_value end, name: __MODULE__)
    pid
  end

  def pid, do: Process.whereis(__MODULE__) || start!()

  def state, do: Agent.get(pid(), & &1)
  def next(), do: Agent.get_and_update(pid(), &{&1, &1 + 1})
end
