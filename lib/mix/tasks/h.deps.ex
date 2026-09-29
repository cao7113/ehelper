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

  alias Mix.PkgCache
  alias Mix.PkgInfo

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

    shell = Mix.shell()
    set_all? = Keyword.has_key?(opts, :all)
    set_top? = Keyword.has_key?(opts, :top_only)

    top_only =
      cond do
        set_all? && set_top? -> Mix.raise("Use one --all or --top-only, not: #{opts |> inspect}!")
        set_all? -> !Keyword.get(opts, :all)
        set_top? -> Keyword.get(opts, :top_only)
        true -> true
      end

    search = Keyword.get(opts, :search)
    conver_opts = if opts[:env_target], do: [env: Mix.env(), target: Mix.target()], else: []
    app = Mix.Project.config()[:app]

    shell.info("## #{app} deps info\n")

    info_opts = Keyword.take(opts, [:force])

    Mix.Dep.Converger.converge(conver_opts)
    |> Enum.reduce([], fn dep, acc ->
      %Mix.Dep{
        top_level: top_level,
        opts: opts,
        app: app
      } = dep

      app_props =
        opts
        |> Keyword.get(:app_properties, [])
        |> Keyword.take([:vsn, :description])
        |> Map.new()

      app = app |> to_string()
      desc = Map.get(app_props, :description, "no description") |> to_string()
      vsn = Map.get(app_props, :vsn, "unknown") |> to_string()

      should_include =
        if top_only do
          top_level
        else
          true
        end

      should_include =
        should_include && matches_search?(app, search)

      if should_include do
        item = %{
          app: app,
          desc: desc,
          vsn: vsn,
          top_level: top_level
        }

        [item | acc]
      else
        acc
      end
    end)
    |> Enum.sort_by(& &1.app)
    |> Enum.map(fn pkg ->
      Task.async(fn ->
        fetch_pkg_info(pkg.app, info_opts)
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

  defp fetch_pkg_info(pkg_app, info_opts) do
    {:ok, PkgCache.get_info(pkg_app, info_opts)}
  rescue
    error ->
      {:error, pkg_app, Exception.message(error)}
  catch
    kind, reason ->
      {:error, pkg_app, "#{kind}: #{inspect(reason)}"}
  end

  def matches_search?(_app, nil), do: true

  def matches_search?(app, search) do
    pattern = Regex.compile!("(?<![\\p{L}\\p{N}])#{Regex.escape(search)}(?![\\p{L}\\p{N}])", "iu")

    Regex.match?(pattern, app)
  end

  def get_dep_doc(%PkgInfo{} = dep, idx) do
    "##{idx + 1} #{dep.app} (#{dep.latest_version})\n#{dep.desc}\n- Docs: #{PkgInfo.docs_url(dep)}\n- Code: #{PkgInfo.github_url(dep)}\n- Pkg.: #{dep.pkg_url}\n- API.: #{dep.api_url}\n"
  end
end
