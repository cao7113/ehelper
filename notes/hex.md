# Hex

- https://github.com/hexpm/hex
- https://hex.pm/api/packages/ecto

mix hex.docs fetch PACKAGE [VERSION]

```
# https://hexdocs.pm/hex_core/readme.html
# config = :hex_core.default_config()
# {:ok, {200, headers, body}} = :hex_repo.get_package(config, "ecto")
# resp = :hex_api_package.get(config, "ecto")
# {:ok, {200, headers, body}} = :hex_api_package.get(:hex_core.default_config(), "ecto")
# iex(32)> body["meta"]["links"]["GitHub"]
# "https://github.com/elixir-ecto/ecto"
{:hex_core, "~> 0.12.0", only: [:dev]},
```

## setup

```
mix local.hex --if-missing # --force
```

## Debug

```
iex(1)> Hex.__info__(:compile)
[
  version: ~c"9.0.2",
  options: [:no_spawn_compiler_process, :from_core, :no_core_prepare,
   :no_auto_import],
  source: ~c"/hex/lib/hex.ex"
]
iex(2)> Application.get_application Hex
:hex

# find
:code.get_path() |> Enum.sort()

# Mix.Local.append_paths() # to load system-env MIX_PATH - appends extra code paths

Mix.path_for(:archives)

# make achive modules available
Mix.Local.append_archives(); Ehelper.hi

iex(2)> Application.started_applications |> Enum.map( & elem(&1, 0) )|> Enum.sort
[:asn1, :bander, :bandit, :compiler, :crypto, :eex, :elixir, :finch, :fss, :hex,
 :hpax, :iex, :inets, :jason, :kernel, :kino, :kino_vega_lite, :logger, :mime,
 :mint, :mint_web_socket, :mix, :nimble_options, :nimble_pool, :plug,
 :plug_crypto, :public_key, :req, :ssl, :stdlib, :table, :telemetry,
 :thousand_island, :vega_lite, :websock, :websock_adapter]

 iex(1)> Application.started_applications |> Enum.map( & elem(&1, 0) )|> Enum.sort
[:compiler, :elixir, :iex, :kernel, :logger, :mix, :stdlib, :tt]
```