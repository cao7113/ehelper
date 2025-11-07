defmodule Mix.Tasks.H.Docs do
  @shortdoc "Common used docs tasks"

  use Mix.Task

  @moduledoc """
  Summarize local deps info managed by ehelper.

  Options:
  - filter: filter dependencies by name or description
  - force: force fetching of dependency information
  """

  @switches []

  @aliases []

  @impl true
  def run(args) do
    {_opts, _, _} = OptionParser.parse(args, strict: @switches, aliases: @aliases)

    # todo
    info = %{
      elixir: %{
        github: "https://github.com/elixir-lang/elixir",
        docs: "https://elixir-lang.org/docs.html",
        mix: "https://hexdocs.pm/mix/Mix.html",
        exunit: "https://hexdocs.pm/ex_unit/ExUnit.html"
      },
      erlang: %{
        docs: "https://www.erlang.org/doc/readme.html",
        otp: "https://www.erlang.org/doc/design_principles/des_princ.html",
        stdlib: "https://www.erlang.org/doc/apps/stdlib/index.html"
      }
    }

    info |> Ehelper.pp()
  end
end
