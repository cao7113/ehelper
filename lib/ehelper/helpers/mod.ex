defmodule Ehelper.Mod do
  @moduledoc """
  Helpers for Elixir's Module module.

  - https://hexdocs.pm/elixir/Module.html#module-generated-functions
  """

  # @compile :debug_info

  @inner_keys Module.reserved_attributes() |> Map.keys() |> Enum.sort()
  def inner_attrs, do: @inner_keys

  def info(mod \\ __MODULE__) when is_atom(mod) do
    [
      as_behavior: behaviour_info_of(mod),
      as_struct: struct_info(mod)
      # module_info: mod_info(mod)
    ]
  end

  def mod_info(mod \\ __MODULE__) when is_atom(mod),
    do: mod.module_info()

  @doc """
  Get module info with __info__

  iex>  URI.__info__(:functions)
  iex>  URI.module_info(:exports)
  """
  def info_of(mod \\ __MODULE__, key \\ :functions) when is_atom(mod) and is_atom(key),
    do: mod.__info__(key)

  @doc """
  Struct info

  iex>  H.Mod.struct_info Task
  """
  def struct_info(mod) do
    mod
    |> info_of(:struct)
    |> case do
      nil ->
        :non_struct_module

      items ->
        items
        |> Enum.sort_by(fn %{field: f} -> f end)
        |> Enum.map(fn %{field: f, default: default} -> {f, default} end)
    end
  end

  @doc """
  Get behaviour module callbacks info

  !!! Prefer iex builtin `b` helper instead
  iex>  b GenServer
  """
  def behaviour_info_of(mod) when is_atom(mod) do
    try do
      mod.behaviour_info(:callbacks)
      |> Enum.sort()
    rescue
      UndefinedFunctionError -> :non_behavior_module
    end
  end
end
