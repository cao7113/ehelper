defmodule Ehelper.CLI do
  def main(_args) do
    IO.puts("Hello from Ehelper CLI!")

    # Req.get!("https://api.github.com/repos/elixir-lang/elixir").body["description"]
    # |> IO.inspect(label: "try req")
  end
end
