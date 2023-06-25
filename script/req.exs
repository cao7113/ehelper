#!/usr/bin/env elixir
# [tag] = System.argv()

Mix.install([
  {:req, "~> 0.2.1"},
  {:jason, "~> 1.0"}
])

Req.get!("https://api.github.com/repos/elixir-lang/elixir").body["description"]
|> IO.inspect(label: "try req")
