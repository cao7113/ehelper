defmodule Ehelper.Behave do
  @moduledoc """
  Demo behavior

  iex> b H.Behave
  """

  @type t() :: atom()

  @callback ping() :: :pong | term()
end

defmodule Ehelper.Behaver do
  defstruct msg: nil

  @behaviour Ehelper.Behave

  def ping, do: :pong
end
