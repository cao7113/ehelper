defmodule Ehelper.Recorder do
  @moduledoc """
  Recorder helper

  https://hexdocs.pm/elixir/Record.html#content

  ## Example

  iex>  require Ehelper.Recorder
  iex>  Recorder.user()

  ## Erlang 中的Record表示
  """

  require Record
  Record.defrecord(:user, name: "john", age: 25)

  @type user :: record(:user, name: String.t(), age: integer)
  # expands to: "@type user :: {:user, String.t(), integer}"

  # The record tag and its fields are stored as metadata in the "Docs" chunk of the record definition macro. You can retrieve the documentation for a module by calling Code.fetch_docs/1.
  def docs, do: Code.fetch_docs(__MODULE__)
end
