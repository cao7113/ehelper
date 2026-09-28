defmodule Mix.Tasks.H.Pkg.Clone do
  @shortdoc "Shallow-clone a Hex package's GitHub repository"

  @moduledoc """
  #{@shortdoc} using the GitHub URL in the package's Hex metadata.

  Package metadata is loaded through `Mix.PkgCache`: cached data is used when
  available, otherwise it is fetched from Hex and cached locally. The clone is
  created at `<destination>/<package>`. If that path already exists, the task
  prints a message and leaves it unchanged.

  The destination defaults to the current working directory. Git must be
  installed and available on `PATH`.

  ## Usage

      mix h.pkg.clone PACKAGE
      mix h.pkg.clone PACKAGE DESTINATION
      mix h.pkg.clone PACKAGE DESTINATION --depth 5
      mix h.pkg.clone PACKAGE --force
      mix h.pkg.clone req _local

  ## Arguments

      * `PACKAGE` - Hex package name to clone.
      * `DESTINATION` - optional parent directory for the package-named clone
        (default: the current working directory).

  ## Options

      * `--depth COMMITS` - number of recent commits to fetch (default: `1`).
    * `-f`, `--force` - refresh cached Hex metadata before looking up the
      GitHub URL. This has no effect when the destination already exists.

  The Hex cache directory defaults to `~/.cache/hex-pkgs`; set
  `MIX_PKGS_INFO_ROOT` to use another directory.
  """

  use Mix.Task

  alias Mix.PkgCache
  alias Mix.PkgInfo

  @switches [depth: :integer, force: :boolean]
  @aliases [d: :depth, f: :force]
  @default_depth 3

  @impl Mix.Task
  def run(args) do
    {opts, args} = OptionParser.parse!(args, strict: @switches, aliases: @aliases)
    {package_name, destination_root} = positional_args!(args)
    depth = Keyword.get(opts, :depth, @default_depth)
    validate_depth!(depth)

    destination_root = Path.expand(destination_root)
    destination = Path.join(destination_root, package_name)

    if File.exists?(destination) do
      Mix.shell().info("Skipping #{package_name}: #{destination} already exists")
    else
      clone_package(package_name, destination_root, destination, depth, opts)
    end
  end

  defp positional_args!([package_name]) do
    {package_name!(package_name), "."}
  end

  defp positional_args!([package_name, destination_root]) when destination_root != "" do
    {package_name!(package_name), destination_root}
  end

  defp positional_args!(_args) do
    Mix.raise(
      "Expected a package name and optional destination. Run `mix help h.pkg.clone` for usage."
    )
  end

  defp package_name!(package_name) do
    case String.trim(package_name) do
      "" -> Mix.raise("Package name cannot be blank")
      name -> name
    end
  end

  defp validate_depth!(depth) when depth > 0, do: :ok

  defp validate_depth!(_depth) do
    Mix.raise("Clone depth must be a positive integer")
  end

  defp clone_package(package_name, destination_root, destination, depth, opts) do
    repository_url =
      package_name
      |> PkgCache.get_info(Keyword.take(opts, [:force]))
      |> PkgInfo.github_url()

    if is_nil(repository_url) do
      Mix.raise("No GitHub URL found in Hex metadata for #{package_name}")
    end

    File.mkdir_p!(destination_root)
    Mix.shell().info("Cloning #{repository_url} into #{destination}")

    case System.cmd(
           "git",
           ["clone", "--depth", Integer.to_string(depth), "--", repository_url, destination],
           stderr_to_stdout: true
         ) do
      {output, 0} ->
        if output != "", do: Mix.shell().info(output)

      {output, exit_code} ->
        Mix.raise("git clone failed for #{package_name} (#{exit_code}):\n#{output}")
    end
  rescue
    error in ErlangError ->
      Mix.raise("Could not run git clone for #{package_name}: #{Exception.message(error)}")
  end
end
