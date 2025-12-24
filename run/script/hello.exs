#!/usr/bin/env elixir

IO.puts("Hello Elixir!")
IO.inspect(System.argv(), label: "system argv")
IO.inspect(System.build_info(), label: "build-info")
IO.inspect(:erlang.process_info(self(), :current_function), label: "current func")
