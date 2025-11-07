# https://hexdocs.pm/elixir/typespecs.html#behaviours

# define behaviour as behaviour module
defmodule Parser do
  @doc """
  Parse a string.
  """
  @callback parse(String.t()) :: {:ok, term()} | {:error, String.t()}

  @doc """
  List file extensions.
  """
  @callback extension() :: [String.t()]
end

# impl behaviour as callback module
defmodule JSONParser do
  @behaviour Parser

  @impl Parser
  def parse(str), do: {:ok, "some json " <> str}

  @impl Parser
  def extension(), do: ["json"]
end

defmodule YAMLParser do
  @behaviour Parser

  @impl Parser
  def parse(str), do: {:ok, "some yaml " <> str}

  @impl Parser
  def extension(), do: ["yml"]
end

defmodule ParserTest do
  use ExUnit.Case

  test "parse ok" do
    assert {:ok, "some json ok"} = JSONParser.parse("ok")
    assert {:ok, "some yaml ok"} = YAMLParser.parse("ok")
  end
end
