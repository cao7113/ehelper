# Ehelper

[![CI](https://github.com/cao7113/ehelper/actions/workflows/ci.yml/badge.svg)](https://github.com/cao7113/ehelper/actions/workflows/ci.yml)
[![Release](https://github.com/cao7113/ehelper/actions/workflows/release.yml/badge.svg)](https://github.com/cao7113/ehelper/actions/workflows/release.yml)
[![Hex](https://img.shields.io/hexpm/v/ehelper)](https://hex.pm/packages/ehelper)

Elixir/Erlang daily helpers and learning playground.

NOTE: mainly used as archive and global utils in .iex.exs, no other dependecies required except elixir!!

## Usage

```
export MIX_DEBUG=1
mix h.hc https://api.github.com/repos/elixir-lang/elixir

# global

mise x elixir erlang -- mix h.hi
```

## Hex package information

`mix h.pkg` lists the Hex package helper tasks. `mix h.pkg info PACKAGE` displays
package metadata, using the local cache when available and fetching from Hex otherwise.

```bash
mix h.pkg
mix h.pkg.info plug
mix h.pkg.info plug --force
mix h.pkg.open plug
mix h.pkg.open plug --kind docs
```

The cache defaults to `~/.cache/hex-pkgs`; set `MIX_PKGS_INFO_ROOT` to use another directory. `--force` refreshes the cached response. `Mix.PkgCache.get_info/2` is the cached programmatic entry point; `Mix.PkgInfo.fetch/2` fetches directly and returns `{:ok, info}` or `{:error, reason}`.

## Check ehelper archive in your project

```
# in mix.exs project/0

archives: [{:ehelper, "~> 0.2"}]
```

## Install

```bash
mix archive.install hex ehelper --force
mix h
mix local

## locally install or update
mix up
```

## Similar projects

- https://github.com/membraneframework/bunch
- [Other old ehelper, intresting?](https://github.com/philosophers-stone/ehelper)

## Links

- https://github.com/phoenixframework/phoenix
- https://github.com/elixir-lang/elixir
- https://elixir-lang.org/docs.html
