#!/usr/bin/env elixir

# with elixir, mix, logger
# :code.get_path() |> dbg

url = List.first(System.argv()) || "https://google.com"
IO.puts("# Fetch url: #{url}")

Application.ensure_all_started(:mix)
Mix.Utils.read_path(url) |> dbg
