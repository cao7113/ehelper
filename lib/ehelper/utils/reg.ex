defmodule Ehelper.Reg do
  @moduledoc """
  Registry helpers
  """

  def name_of(pid) when is_pid(pid) do
    Process.info(pid, :registered_name)
    |> case do
      {_, name} -> name
      nil -> pid
    end
  end

  def find_name(pid), do: name_of(pid)
  def find_pid(name), do: Process.whereis(name)

  def local_registered_names(), do: Process.registered() |> Enum.sort()
  def names, do: local_registered_names()

  def filter_name(name) do
    name = to_string(name)

    local_registered_names()
    |> Enum.filter(fn n ->
      n
      |> to_string()
      |> String.downcase()
      |> String.contains?(String.downcase(name))
    end)
    |> Enum.map(fn n ->
      {n, Process.whereis(n)}
    end)
  end

  def filter_with(fun) when is_function(fun, 1) do
    local_registered_names()
    |> Enum.filter(fn n -> fun.(n) end)
  end
end
