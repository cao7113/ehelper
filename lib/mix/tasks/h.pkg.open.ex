defmodule Mix.Tasks.H.Pkg.Open do
  @shortdoc "Open a Hex package link in the browser"

  @moduledoc """
  #{@shortdoc} using the package metadata cached by `Mix.PkgCache`.

  By default, opens the first available link in this order: GitHub, documentation,
  then the Hex package page. Use `--kind docs` to open the documentation link.

  ## Usage

      mix h.pkg.open PACKAGE
      mix h.pkg.open PACKAGE --kind docs
      mix h.pkg.open PACKAGE --force

  ## Options

    * `-f`, `--force` - refresh Hex metadata before selecting a URL.
    * `-k`, `--kind KIND` - select `docs` (or `doc`) instead of the default link.

  The cache directory defaults to `~/.cache/hex-pkgs`; set
  `MIX_PKGS_INFO_ROOT` to use another directory.
  """

  use Mix.Task

  alias Mix.PkgCache
  alias Mix.PkgInfo

  @switches [force: :boolean, kind: :string]
  @aliases [f: :force, k: :kind]

  @impl Mix.Task
  def run(args) do
    {opts, args} = OptionParser.parse!(args, strict: @switches, aliases: @aliases)
    package_name = package_name!(args)
    info = PkgCache.get_info(package_name, Keyword.take(opts, [:force]))
    url = url_for!(info, opts[:kind])

    Mix.shell().info("Opening URL: #{url}")
    open_url!(url)
  end

  defp package_name!([package_name]) do
    case String.trim(package_name) do
      "" -> Mix.raise("Package name cannot be blank")
      name -> name
    end
  end

  defp package_name!(_args) do
    Mix.raise("Expected exactly one package name. Run `mix help h.pkg.open` for usage.")
  end

  defp url_for!(info, kind) when kind in ["doc", "docs"] do
    case PkgInfo.docs_url(info) do
      nil -> Mix.raise("No documentation URL found for #{info.app}")
      url -> url
    end
  end

  defp url_for!(info, nil) do
    case PkgInfo.github_url(info) || PkgInfo.docs_url(info) || info.pkg_url do
      nil -> Mix.raise("No GitHub, documentation, or Hex package URL found for #{info.app}")
      url -> url
    end
  end

  defp url_for!(_info, kind) do
    Mix.raise("Unsupported link kind #{inspect(kind)}; expected `docs` or `doc`")
  end

  defp open_url!(url) do
    {command, args} =
      case :os.type() do
        {:unix, :darwin} -> {"open", [url]}
        {:unix, _} -> {"xdg-open", [url]}
        {:win32, _} -> {"rundll32", ["url.dll,FileProtocolHandler", url]}
      end

    case System.cmd(command, args, stderr_to_stdout: true) do
      {_output, 0} -> :ok
      {output, exit_code} -> Mix.raise("Could not open #{url} (#{exit_code}): #{output}")
    end
  rescue
    error in ErlangError ->
      Mix.raise("Could not open #{url}: #{Exception.message(error)}")
  end
end
