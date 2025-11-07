#!/usr/bin/env elixir

IO.puts("Hello Elixir!")
IO.inspect(:erlang.process_info(self(), :current_function))
