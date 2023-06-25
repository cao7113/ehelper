defmodule Mix.Tasks.Req do
  @shortdoc "try req"

  use Mix.Task

  @impl true
  def run(args) do
    Req.get!("https://api.github.com/repos/elixir-lang/elixir").body["description"]
    |> IO.inspect(label: "try req")
  end
end
