# iex 

```
$ MIX_DEBUG=1 iex -S mix run
$ ELIXIR_CLI_DRY_RUN=1 iex
$ ELIXIR_CLI_DRY_RUN=1 mix
$ ELIXIR_CLI_DRY_RUN=1 iex -S mix

erl -noshell -elixir_root /Users/rj/.asdf/installs/elixir/1.19.2-otp-28/bin/../lib -pa /Users/rj/.asdf/installs/elixir/1.19.2-otp-28/bin/../lib/elixir/ebin -user elixir -extra --no-halt +iex -S mix

require IEx; IEx.pry()
```

## Helpers

- https://hexdocs.pm/iex/IEx.Helpers.html

```
iex> h
iex> h v/0
iex> respwan # create new iex session and close previous
iex> runtime_info
iex> exports IEx.Helpers

#iex:break
```

## Charlist

```
iex(1)> inspect(~c"abc", charlists: :as_list)
"[97, 98, 99]"

iex> i ~c"abc"
# Raw representation
#  [97, 98, 99] 
iex> i 'abc'
#Raw representation
#  [97, 98, 99]
iex> i "abc"
#Raw representation
#  <<97, 98, 99>>
```