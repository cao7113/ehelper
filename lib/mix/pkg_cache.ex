defmodule Mix.PkgCache do
  @moduledoc """
  Cache Hex package metadata locally.

  `get_info/2` returns cached package metadata when available; otherwise it
  fetches the package from Hex and stores the response locally. Fetched
  metadata is always cached. Pass `force: true` to refresh an existing entry.

  ## Options

    * `:force` - fetch from Hex even when a cached entry exists (default: `false`).
    * `:timeout` - HTTP request timeout in milliseconds or `:infinity`.
    * `:debug` - enable HTTP client debug logging (default: `false`).
    * `:proxy` - use the proxy configuration from the environment (`:env`), or
      disable proxy use (`false` or `:no`).

  The network options are passed to `Mix.PkgInfo.fetch/2`. The cache directory
  defaults to `~/.cache/hex-pkgs`; set `MIX_PKGS_INFO_ROOT` to use another
  directory. There is no option to disable caching.

  ## Example

      req = Mix.PkgCache.get_info("req")
      req.latest_version

  Force a refresh and set a request timeout:

      req = Mix.PkgCache.get_info("req", force: true, timeout: 10_000)
  """

  alias Mix.PkgInfo

  @default_cache_root "~/.cache/hex-pkgs"

  def get_info(pkg, opts \\ []) do
    pkg = to_string(pkg)
    cache_path = pkg_cache_path(pkg)

    if File.regular?(cache_path) and not Keyword.get(opts, :force, false) do
      cache_path
      |> File.read!()
      |> JSON.decode!()
      |> PkgInfo.from_api_body()
    else
      fetch_and_cache(pkg, cache_path, opts)
    end
  end

  defp fetch_and_cache(pkg, cache_path, opts) do
    IO.puts("# [#{pkg}] loading pkg info into: #{cache_path}")
    started_at = System.monotonic_time(:millisecond)

    case PkgInfo.fetch(pkg, Keyword.put(opts, :raw, true)) do
      {:ok, body} ->
        File.write!(cache_path, JSON.encode!(body))

        elapsed_ms = System.monotonic_time(:millisecond) - started_at
        IO.puts("# [#{pkg}] fetched pkg info taken: #{elapsed_ms} ms")

        PkgInfo.from_api_body(body)

      {:error, reason} ->
        raise "Unable to fetch Hex package #{pkg}: #{inspect(reason)}"
    end
  end

  def pkg_cache_path(name) when is_binary(name) do
    Path.join(pkgs_cache_root(), "#{name}.json")
  end

  def pkgs_cache_root(opts \\ []) do
    root =
      System.get_env("MIX_PKGS_INFO_ROOT", @default_cache_root)
      |> Path.expand()

    if Keyword.get(opts, :make_dirs, true), do: File.mkdir_p!(root)
    root
  end
end
