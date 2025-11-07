#!/usr/bin/env elixir

Mix.install([
  {:req, "~> 0.5"}
])

%{
  status: 200,
  body: body
} =
  Req.get!("https://httpbin.org/ip")

body
|> dbg
