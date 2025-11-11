defmodule Ehelper.Counter do
  @moduledoc """
  Agent helper

  https://hexdocs.pm/elixir/Agent.html

  In fact Agent is very simple GenServer based process with some handy state get-and-update utilities!
  """

  use Agent

  def start_link(init_value \\ 0) when is_integer(init_value) do
    Agent.start_link(fn -> init_value end, name: __MODULE__)
  end

  def pid, do: Process.whereis(__MODULE__)

  def value, do: Agent.get(__MODULE__, & &1)
  def val, do: value()

  def state, do: Agent.get(pid(), & &1)
  def next(), do: Agent.get_and_update(pid(), &{&1, &1 + 1})
  def n, do: next()
end
