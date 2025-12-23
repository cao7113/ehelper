defmodule Mix.Tasks.H.Deps do
  @shortdoc "Show project deps info friendly"

  @moduledoc """
  #{@shortdoc}.

  Options:
  - search: search dependencies by name or description
  - env-target: load dependencies for the current environment and target
  - top-only: include top-level only deps
  - all:      include all deps, exclusive with top-only
  - force: force fetching of dependency information
  """

  use Mix.Task
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
        if search do
          (String.contains?(desc, search) || String.contains?(app, search)) && should_include
        else
          should_include
        end

      if should_include do
        item = %{
          app: app,
          desc: desc,
          vsn: vsn,
          top_level: top_level
        }

        acc ++ [item]
      else
        acc
      end
    end)
    |> Enum.sort_by(& &1.app)
    |> Enum.map(fn pkg ->
      Task.async(fn ->
        PkgInfo.get_info(pkg.app, info_opts)
      end)
    end)
    |> Task.await_many()
    |> Enum.with_index(fn dep, idx ->
      info = get_dep_doc(dep, idx)
      shell.info(info)
    end)
  end

  def get_dep_doc(%PkgInfo{} = dep, idx) do
    "##{idx + 1} #{dep.app} (#{dep.latest_version})\n#{dep.desc}\n- Docs: #{PkgInfo.docs_url(dep)}\n- Code: #{PkgInfo.github_url(dep)}\n- Pkg.: #{dep.pkg_url}\n- API.: #{dep.api_url}\n"
  end

  # %Mix.Dep{
  #   requirement: nil,
  #   extra: [],
  #   from: nil,
  #   system_env: [],
  #   manager: :mix,
  #   deps: [],
  #   top_level: true,
  #   status: {:ok, "1.4.44"},
  #   opts: [app_properties: [vsn: ~c""], description: ~c""],
  #   app: app
  # }
end
