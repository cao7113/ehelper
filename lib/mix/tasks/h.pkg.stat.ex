defmodule Mix.Tasks.H.Pkg.Stat do
  @shortdoc "Show statistics for the local Hex package metadata cache"

  @moduledoc """
  #{@shortdoc}.

  The cache directory defaults to `~/.cache/hex-pkgs`. Set
  `MIX_PKGS_INFO_ROOT` to use a different directory. The directory is created
  if it does not exist.

  The report includes the cache path, total disk usage in KiB, the number of
  cached package JSON files, up to five package names, and the directory's
  local access, modification, and change times.

  ## Usage

      mix h.pkg.stat

  This task does not fetch or refresh package metadata; use `mix h.pkg --force
  PACKAGE` to refresh a specific package.
  """

  use Mix.Task
  alias Mix.PkgCache

  @impl true
  def run(_args) do
    root = PkgCache.pkgs_cache_root()
    files = Path.wildcard(Path.join(root, "*.json"))
    names = Enum.map(files, &Path.basename(&1, ".json"))
    timings = File.stat!(root, time: :local) |> Map.take([:atime, :mtime, :ctime])

    %{
      root: root,
      disk_in_kb: Ehelper.File.du_ksize(root),
      rand_names: Enum.take_random(names, 5),
      timings: timings,
      files_count: Enum.count(names)
    }
    |> Ehelper.pp()
  end
end
