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
