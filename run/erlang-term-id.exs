#!/usr/bin/env elixir
# https://github.com/elixir-lang/elixir/blob/1921765c787b8c28efda04e97f48cc03fe852514/lib/mix/lib/mix.ex#L932C1-L936C43

{:some, [1, 2, 3], "info"}
|> :erlang.term_to_binary()
|> :erlang.md5()
|> Base.url_encode64(padding: false)
|> IO.inspect(label: "md5-term-id")

{:some, [1, 2, 3], "info"}
|> :erlang.term_to_binary()
# https://www.erlang.org/doc/apps/erts/erlang.html#phash2/2
# The function returns a hash value for Term within the range 0..Range-1. The maximum value for Range is 2^32. When without argument Range, a value in the range 0..2^27-1 is returned.
|> :erlang.phash2(2 ** 32)
|> IO.inspect(label: "phase2-term-id")

## compare size
obj = %{
  string: String.duplicate("abc", 200),
  numbers: Enum.to_list(1..1000),
  float: 1.23456789,
  nested: %{a: 1, b: [2, 3, %{c: "deep"}]}
}

obj |> :erlang.term_to_binary() |> byte_size() |> IO.inspect(label: "binary-size")
obj |> JSON.encode!() |> byte_size() |> IO.inspect(label: "json-size")
# binary-size: 285
# json-size: 466
