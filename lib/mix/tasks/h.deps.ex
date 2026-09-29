defmodule Mix.Tasks.H.Deps do
  @shortdoc "Show dependency metadata and Hex package links"

  @moduledoc """
  #{@shortdoc}.

  By default, lists top-level dependencies. Package metadata is loaded from the
  local cache or fetched from Hex. If metadata for a package cannot be loaded,
  the task prints a warning for that package and continues with the rest.

  ## Examples

      mix h.deps
      mix h.deps --search plug
      mix h.deps --all
      mix h.deps --force --env-target

  ## Options

    * `-s`, `--search TERM` - filter by a case-insensitive whole word or phrase
      in the dependency name.
    * `-t`, `--top-only` - show only top-level dependencies (the default).
    * `-a`, `--all` - include transitive dependencies; cannot be combined with
      `--top-only`.
    * `-e`, `--env-target` - converge dependencies for the current environment
      and target.
    * `-f`, `--force` - fetch fresh package metadata from Hex, bypassing cache.
  """

  use Mix.Task

  alias Mix.DepInfo

  @switches [
    force: :boolean,
    env_target: :boolean,
    top_only: :boolean,
    all: :boolean,
    search: :string
  ]

  @aliases [
    f: :force,
    e: :env_target,
    t: :top_only,
    a: :all,
    s: :search
  ]

  @impl true
  def run(args) do
    Mix.Project.get!()

    {opts, _} = OptionParser.parse!(args, strict: @switches, aliases: @aliases)
    set_all? = Keyword.get(opts, :all, false)
    set_top? = Keyword.get(opts, :top_only, true)

    top_only =
      cond do
        set_all? && set_top? ->
          Mix.raise("Use --all or --top-only, not both: #{opts |> inspect}!")

        set_all? ->
          false

        true ->
          true
      end

    search = Keyword.get(opts, :search)
    app = Mix.Project.config()[:app]

    shell = Mix.shell()
    shell.info("## #{app}-#{Mix.Project.config()[:version]} deps info\n")

    info_opts = Keyword.take(opts, [:force])

    DepInfo.list(env_target: opts[:env_target])
    |> Enum.filter(fn dep ->
      (not top_only or dep.top_level) and matches_search?(to_string(dep.app), search)
    end)
    |> Enum.sort_by(& &1.app)
    |> Enum.map(fn pkg ->
      Task.async(fn ->
        DepInfo.enrich(pkg, info_opts)
      end)
    end)
    |> Task.await_many()
    |> Enum.reduce(0, fn
      {:ok, dep}, idx ->
        shell.info(get_dep_doc(dep, idx))
        idx + 1

      {:error, pkg_app, reason}, idx ->
        shell.error("Skipping #{pkg_app}: could not load package metadata (#{reason})")
        idx
    end)
  end

  def matches_search?(_app, nil), do: true

  def matches_search?(app, search) do
    pattern = Regex.compile!("(?<![\\p{L}\\p{N}])#{Regex.escape(search)}(?![\\p{L}\\p{N}])", "iu")

    Regex.match?(pattern, app)
  end

  def get_dep_doc(%DepInfo{} = dep, idx) do
    versions =
      [version_label("locked", dep.locked_version), version_label("latest", dep.latest_version)]
      |> Enum.reject(&is_nil/1)
      |> Enum.join(", ")

    title = "##{idx + 1} #{dep.app}#{if versions == "", do: "", else: " (#{versions})"}"

    details =
      [
        dep.description,
        detail_line("Source type", dep.source_type),
        detail_line("Source", dep.source),
        detail_line("Tag", dep.tag),
        detail_line("Commit", dep.revision),
        detail_line("Sparse checkout", dep.sparse),
        detail_line("Path", dep.path),
        detail_line("Docs", dep.docs_url),
        detail_line("Code", dep.links["GitHub"] || dep.links["github"]),
        detail_line("Pkg.", dep.pkg_url),
        detail_line("API.", dep.api_url)
      ]
      |> Enum.reject(&is_nil/1)

    Enum.join([title | details], "\n") <> "\n"
  end

  defp version_label(_label, nil), do: nil
  defp version_label(label, version), do: "#{label}: #{version}"

  defp detail_line(_label, nil), do: nil
  defp detail_line(label, value), do: "- #{label}: #{value}"
end
