#!/usr/bin/env elixir

Mix.install([
  {:req, "~> 0.5"}
])

Req.get!("https://httpbin.org/ip")
|> dbg
