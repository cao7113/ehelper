defmodule Mix.Tasks.H.Deps do
  @shortdoc "Show project deps info friendly"

  @moduledoc """
  #{@shortdoc}.

  Options:
  - filter: filter dependencies by name or description
  - current_env: load dependencies for the current environment and target
  - all: include all dependencies, not just top-level ones
  - full: display full information for each dependency
  - force: force fetching of dependency information
  """

  use Mix.Task
  alias Mix.DepInfo

  @switches [
    force: :boolean,
    current_env: :boolean,
    all: :boolean,
    full: :boolean,
    filter: :string
  ]

  @aliases [
    # f: :force,
    c: :current_env,
    a: :all,
    f: :full
  ]

  @impl true
  def run(args) do
    Mix.Project.get!()
    app = Mix.Project.config()[:app]
    {opts, _, _} = OptionParser.parse(args, strict: @switches, aliases: @aliases)
    all? = Keyword.get(opts, :all, false)
    full_info = Keyword.get(opts, :full, false)
    loaded_opts = if opts[:current_env], do: [env: Mix.env(), target: Mix.target()], else: []
    filter = Keyword.get(opts, :filter, nil)

    pkgs =
      Mix.Dep.Converger.converge(loaded_opts)
      |> Enum.reduce([], fn dep, acc ->
        %Mix.Dep{
          # manager: :mix,
          # scm: Hex.SCM,
          # status: {:ok, "1.4.44"},
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
            if filter do
              String.contains?(desc, filter) or String.contains?(app, filter)
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
        info =
          "##{idx + 1} #{dep.app} (#{dep.latest_version})\n#{dep.desc}\n- Code: #{DepInfo.github_url(dep)}\n- Docs: #{DepInfo.docs_url(dep)}\n- Pkg.: #{dep.pkg_url}\n- API.: #{dep.api_url}\n"

        shell.info(info)
      end
    end)
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
