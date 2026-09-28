defmodule Mix.Tasks.H.Pkg.Info do
  @shortdoc "Show cached or fetched Hex package information"

  @moduledoc """
  #{@shortdoc}.

  Package metadata is loaded through `Mix.PkgCache.get_info/2`. If a cached
  entry exists, it is displayed without a network request. Otherwise, metadata
  is fetched from Hex, saved to the local cache, and displayed.

  The cache directory defaults to `~/.cache/hex-pkgs`. Set
  `MIX_PKGS_INFO_ROOT` to use a different directory.

  ## Usage

      mix h.pkg info PACKAGE
      mix h.pkg info PACKAGE --force
      mix h.pkg.info PACKAGE

  ## Options

    * `-f`, `--force` - fetch fresh metadata from Hex even when a cached entry
      exists. The fetched metadata replaces the cached entry.
  """

  use Mix.Task
  alias Mix.PkgCache

  @switches [force: :boolean]
  @aliases [f: :force]

  @impl true
  def run(args) do
    {opts, args} = OptionParser.parse!(args, strict: @switches, aliases: @aliases)
    package_name = package_name!(args)
    info = PkgCache.get_info(package_name, opts)
    Ehelper.pp(info)
  end

  defp package_name!([package_name]) do
    case String.trim(package_name) do
      "" -> Mix.raise("Package name cannot be blank")
      name -> name
    end
  end

  defp package_name!(_args) do
    Mix.raise("Expected exactly one package name. Run `mix help h.pkg.info` for usage.")
  end
end
