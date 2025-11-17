# Tools

## observer

- https://hexdocs.pm/elixir/debugging.html#observer

## crash viewer

- https://www.erlang.org/doc/apps/observer/crashdump_viewer.html
- https://www.erlang.org/doc/apps/observer/crashdump_ug

```
$ asdf which cdv
$ cdv
```

## etop

```
$ etop
```

## Microstate accounting

- https://www.erlang.org/doc/apps/runtime_tools/msacc.html

```
iex> Mix.ensure_application!(:msacc)
iex> :msacc.start(1000)
iex> :msacc.print()
```