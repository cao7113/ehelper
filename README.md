# Ehelper

[![CI](https://github.com/cao7113/ehelper/actions/workflows/ci.yml/badge.svg)](https://github.com/cao7113/ehelper/actions/workflows/ci.yml)
[![Release](https://github.com/cao7113/ehelper/actions/workflows/release.yml/badge.svg)](https://github.com/cao7113/ehelper/actions/workflows/release.yml)
[![Hex](https://img.shields.io/hexpm/v/ehelper)](https://hex.pm/packages/ehelper)

Elixir/Erlang daily helpers and learning playground.

NOTE: mainly used as archive and global utils in .iex.exs, no other dependecies required except elixir!!

## Usage

```
export MIX_DEBUG=1 
mix h.cget https://api.github.com/repos/elixir-lang/elixir
```

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