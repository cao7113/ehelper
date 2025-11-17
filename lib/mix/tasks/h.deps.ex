defmodule Mix.Tasks.H.Deps do
  @shortdoc "Show project deps info friendly"

  @moduledoc """
  #{@shortdoc}.

  Options:
  - search: search dependencies by name or description
  - env_and_target: load dependencies for the current environment and target
  - all: include all dependencies, not just top-level ones
  - full: display full information for each dependency
  - force: force fetching of dependency information
  """

  use Mix.Task
  alias Mix.DepInfo

  @switches [
    force: :boolean,
    env_and_target: :boolean,
    all: :boolean,
    full: :boolean,
    search: :string
  ]

  @aliases [
    # f: :force,
    e: :env_and_target,
    a: :all,
    f: :full,
    s: :search
  ]

  @impl true
  def run(args) do
    Mix.Project.get!()
    app = Mix.Project.config()[:app]
    {opts, _, _} = OptionParser.parse(args, strict: @switches, aliases: @aliases)
    all? = Keyword.get(opts, :all, false)
    full_info = Keyword.get(opts, :full, false)
    loaded_opts = if opts[:env_and_target], do: [env: Mix.env(), target: Mix.target()], else: []
    search = Keyword.get(opts, :search, nil)

    pkgs =
      Mix.Dep.Converger.converge(loaded_opts)
      |> Enum.reduce([], fn dep, acc ->
        %Mix.Dep{
          top_level: top_level,
          opts: opts,
          app: app
        } = dep

        if all? or top_level do
          app_props =
            opts
            |> Keyword.get(:app_properties, [])
            |> Keyword.take([:vsn, :description])
            |> Map.new()

          app = app |> to_string()
          desc = Map.get(app_props, :description, "no description") |> to_string()
          vsn = Map.get(app_props, :vsn, "unknown") |> to_string()

          should_include =
            if search do
              String.contains?(desc, search) or String.contains?(app, search)
            else
              true
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
        else
          acc
        end
      end)
      |> Enum.sort_by(& &1.app)

    shell = Mix.shell()
    shell.info("## #{app} deps info\n")

    info_opts = Keyword.take(opts, [:force])

    pkgs
    |> Enum.map(fn pkg ->
      Task.async(fn ->
        DepInfo.get_info(pkg.app, info_opts)
      end)
    end)
    |> Task.await_many()
    |> Enum.with_index(fn dep, idx ->
      if full_info do
        Ehelper.pp(dep)
      else
        info = get_dep_doc(dep, idx)
        shell.info(info)
      end
    end)
  end

  def get_dep_doc(%DepInfo{} = dep, idx) do
    "##{idx + 1} #{dep.app} (#{dep.latest_version})\n#{dep.desc}\n- Docs: #{DepInfo.docs_url(dep)}\n- Code: #{DepInfo.github_url(dep)}\n- Pkg.: #{dep.pkg_url}\n- API.: #{dep.api_url}\n"
  end

  # %Mix.Dep{
  #   # requirement: nil,
  #   # extra: extra,
  #   # from: nil,
  #   # system_env: [],
  #   # :mix
  #   # manager: manager,
  #   # scm: Hex.SCM,
  #   # scm: scm,
  #   # deps: [],
  #   top_level: top_level,
  #   # {:ok, "1.4.44"}
  #   # status: status,
  #   # [app_properties: [vsn: ~c""], description: ~c""]
  #   opts: opts,
  #   app: app
  # }
end
