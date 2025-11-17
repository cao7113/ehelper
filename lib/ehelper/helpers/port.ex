defmodule Ehelper.Port do
  @moduledoc """
  Port related helper functions
  - https://hexdocs.pm/elixir/Port.html
  """

  @doc """
    Parse port from string

    PortHelper.parse!("#Port<0.5>)
  """
  def parse!(port_str) when is_binary(port_str) do
    :erlang.list_to_port(port_str |> String.to_charlist())
  end
end
