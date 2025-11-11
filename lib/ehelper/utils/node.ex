defmodule Ehelper.Node do
  @moduledoc """
  Distribution and node helpers
  """

  def info do
    %{
      node: Node.self(),
      cookie: Node.get_cookie(),
      nodes: Node.list(),
      site: site_of_node(Node.self())
    }
  end

  # :erpc.call(:"s1@127.0.0.1", fn -> Slink.build_info end)

  def connect(node, cookie \\ nil) when is_binary(node) do
    node = node |> norm_atom()

    if cookie do
      Node.set_cookie(node, norm_atom(cookie))
    end

    Node.connect(node)
    info()
  end

  def site_of_node(node) do
    node = norm_atom(node)

    if node == Node.self() do
      System.fetch_env!("SITE")
    else
      {:ok, site} =
        node
        |> norm_atom()
        |> :erpc.call(System, :fetch_env, ["SITE"])

      site
    end
  end

  def norm_atom(node) when is_binary(node), do: node |> String.to_atom()
  def norm_atom(node), do: node
end

# H.Node.info()
