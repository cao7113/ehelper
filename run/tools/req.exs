#!/usr/bin/env elixir
# [tag] = System.argv()

# todo repo name and
#  put tools in system PATH
#  httpc version
# use reqer

Mix.install([
  {:req, "~> 0.5"}
])

Req.get!("https://api.github.com/repos/elixir-lang/elixir").body["description"]
|> IO.inspect(label: "try req")
