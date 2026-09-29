defmodule Mix.DepInfo do
  @moduledoc """
  Resolve Mix dependencies into a shared data model and enrich Hex dependencies
  with cached package metadata.
  """

  alias Mix.PkgCache
  alias Mix.PkgInfo

  defstruct app: nil,
            top_level: false,
            package: nil,
            source_type: nil,
            source_label: nil,
            source: nil,
            locked_version: nil,
            latest_version: nil,
            requirement: nil,
            tag: nil,
            revision: nil,
            sparse: nil,
            checkout: nil,
            path: nil,
            mix_app: nil,
            compile: nil,
            children: nil,
            description: nil,
            links: %{},
            pkg_url: nil,
            docs_url: nil,
            api_url: nil

  @doc "Resolve dependencies for the current project and environment."
  def dependencies(opts \\ []) do
    converge_opts =
      if Keyword.get(opts, :env_target, false) do
        [env: Mix.env(), target: Mix.target()]
      else
        []
      end

    Mix.Dep.Converger.converge(converge_opts)
  end

  @doc "Return normalized information for the current project's dependencies."
  def list(opts \\ []) do
    opts
    |> dependencies()
    |> Enum.map(&normalize/1)
  end

  @doc "Find a raw Mix.Dep by its exact application name."
  def find(app, opts \\ []) do
    app = to_string(app)

    case Enum.find(dependencies(opts), &(Atom.to_string(&1.app) == app)) do
      nil -> {:error, "Dependency #{app} not found in the project."}
      dep -> {:ok, dep}
    end
  end

  @doc "Find one dependency and return normalized, cached package information."
  def find_info(app, opts \\ []) do
    with {:ok, dep} <- find(app, opts) do
      dep
      |> normalize()
      |> enrich(opts)
    end
  end

  @doc "Convert a Mix.Dep into the shared dependency representation."
  def normalize(%Mix.Dep{} = dep) do
    base = %__MODULE__{
      app: dep.app,
      top_level: dep.top_level,
      source_type: scm_type(dep.scm),
      source_label: source_label(dep.scm),
      source: scm_source(dep.scm, dep.opts),
      locked_version: status_version(dep.status),
      requirement: dep.requirement,
      tag: dep.opts[:tag],
      sparse: dep.opts[:sparse],
      checkout: dep.opts[:checkout],
      path: dep.opts[:dest],
      mix_app: dep.opts[:app],
      compile: dep.opts[:compile]
    }

    case dep.opts[:lock] do
      {:hex, package, version, _checksum, _mix, children, _repo, _outer_checksum} ->
        %{
          base
          | package: to_string(package),
            source_type: if(base.source_type == "Unknown", do: "Hex", else: base.source_type),
            locked_version: version,
            children: Enum.map(children, &normalize_child/1)
        }

      {:git, repository, revision, git_opts} ->
        %{
          base
          | source_type: "Git",
            source_label: "Repository",
            source: repository,
            tag: Keyword.get(git_opts, :tag, base.tag),
            revision: revision,
            sparse: Keyword.get(git_opts, :sparse, base.sparse)
        }

      _ ->
        base
    end
  end

  @doc "Fetch cached Hex metadata for a normalized dependency, if applicable."
  def enrich(dep, opts \\ [])

  def enrich(%__MODULE__{package: nil} = dep, _opts), do: {:ok, dep}

  def enrich(%__MODULE__{} = dep, opts) do
    pkg_info =
      PkgCache.get_info(dep.package, Keyword.take(opts, [:force, :timeout, :debug, :proxy]))

    {:ok,
     %{
       dep
       | latest_version: pkg_info.latest_version,
         description: blank_to_nil(pkg_info.desc),
         links: pkg_info.links,
         pkg_url: pkg_info.pkg_url || hex_package_url(dep.package),
         docs_url: PkgInfo.docs_url(pkg_info),
         api_url: pkg_info.api_url
     }}
  rescue
    error -> {:error, dep.app, Exception.message(error)}
  catch
    kind, reason -> {:error, dep.app, "#{kind}: #{inspect(reason)}"}
  end

  defp normalize_child({name, requirement, _opts}) do
    app = to_string(name)

    %{app: app, version: requirement, pkg_url: hex_package_url(app)}
  end

  defp scm_type(Mix.SCM.Hex), do: "Hex"
  defp scm_type(Hex.SCM), do: "Hex"
  defp scm_type(Mix.SCM.Git), do: "Git"
  defp scm_type(Mix.SCM.Path), do: "Path"
  defp scm_type(nil), do: "Unknown"
  defp scm_type(scm), do: inspect(scm)

  defp source_label(Mix.SCM.Git), do: "Repository"
  defp source_label(Mix.SCM.Path), do: "Path source"
  defp source_label(_scm), do: "Source"

  defp scm_source(Mix.SCM.Git, opts), do: opts[:git]
  defp scm_source(Mix.SCM.Path, opts), do: opts[:path]
  defp scm_source(_scm, _opts), do: nil

  defp status_version({:ok, version}) when is_binary(version), do: version
  defp status_version(_status), do: nil

  defp hex_package_url(package), do: "https://hex.pm/packages/#{URI.encode(package)}"

  defp blank_to_nil(value) when is_binary(value),
    do: if(String.trim(value) == "", do: nil, else: value)
end
