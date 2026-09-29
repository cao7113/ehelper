defmodule Mix.Tasks.H.Dep.Info do
  @shortdoc "Show locked dependency information and Hex package links"

  @moduledoc """
  #{@shortdoc}.

  The selected dependency must be declared in the current Mix project. Its
  locked version and child dependency requirements come from the project's
  lock entry. Hex description and project links come from `Mix.PkgCache`; the
  dependency's `mix.exs` is not loaded or evaluated.

  On a cache miss, Hex metadata is fetched from `hex.pm` and cached. The cache
  defaults to `~/.cache/hex-pkgs`; set `MIX_PKGS_INFO_ROOT` to change it. Pass
  `--force` to refresh the selected package metadata.

  Git and path dependencies are shown without Hex metadata.

  ## Examples

      mix h.dep.info ex_doc
      mix h.dep.info ex_doc --force
  """

  use Mix.Task
  alias Mix.PkgCache
  alias Mix.PkgInfo

  @switches [force: :boolean]
  @aliases [f: :force]

  @impl Mix.Task
  def run(args) do
    {opts, args} = OptionParser.parse!(args, strict: @switches, aliases: @aliases)

    case args do
      [dep_name] ->
        dep_name
        |> fetch_dep_info(opts)
        |> print_dep_info()

      _ ->
        Mix.raise("Expected one dependency name. Run `mix help h.dep.info` for usage.")
    end
  end

  def fetch_dep_info(dep_name, opts \\ []) do
    try do
      with {:ok, dep} <- find_dep(dep_name) do
        {:ok, build_dep_info(dep, opts)}
      end
    rescue
      error -> {:error, Exception.message(error)}
    end
  end

  def find_dep(dep_name) do
    dep_name = to_string(dep_name)

    case Enum.find(Mix.Dep.cached(), &(Atom.to_string(&1.app) == dep_name)) do
      nil -> {:error, "Dependency #{dep_name} not found in the project."}
      dep -> {:ok, dep}
    end
  end

  defp build_dep_info(dep, opts) do
    base = %{
      app: dep.app,
      path: dep.opts[:dest],
      source_type: scm_name(dep.scm),
      source_label: source_label(dep.scm),
      source: scm_source(dep),
      version: status_version(dep.status),
      tag: dep.opts[:tag],
      revision: nil,
      sparse: dep.opts[:sparse],
      checkout: dep.opts[:checkout],
      mix_app: dep.opts[:app],
      compile: dep.opts[:compile],
      pkg_url: nil,
      docs_url: nil,
      links: %{},
      description: nil,
      children: nil
    }

    case dep.opts[:lock] do
      {:hex, package, version, _checksum, _mix, children, _repo, _outer_checksum} ->
        package = to_string(package)
        pkg_info = PkgCache.get_info(package, opts)

        %{
          base
          | version: version,
            pkg_url: pkg_info.pkg_url || hex_package_url(package),
            docs_url: PkgInfo.docs_url(pkg_info),
            links: pkg_info.links,
            description: blank_to_nil(pkg_info.desc),
            children: Enum.map(children, &child_info/1)
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

  defp scm_name(Mix.SCM.Git), do: "Git"
  defp scm_name(Mix.SCM.Path), do: "Path"
  defp scm_name(Mix.SCM.Hex), do: "Hex"
  defp scm_name(scm), do: inspect(scm)

  defp source_label(Mix.SCM.Git), do: "Repository"
  defp source_label(_scm), do: "Source"

  defp scm_source(%{scm: Mix.SCM.Git, opts: opts}), do: opts[:git]
  defp scm_source(%{scm: Mix.SCM.Path, opts: opts}), do: opts[:path]
  defp scm_source(_dep), do: nil

  defp status_version({:ok, version}) when is_binary(version), do: version
  defp status_version(_status), do: nil

  defp child_info({name, requirement, _opts}) do
    app = to_string(name)

    %{app: app, version: requirement, pkg_url: hex_package_url(app)}
  end

  defp hex_package_url(package), do: "https://hex.pm/packages/#{URI.encode(package)}"

  defp blank_to_nil(value) when is_binary(value),
    do: if(String.trim(value) == "", do: nil, else: value)

  def format_dep_info(info) do
    title = "#{info.app}#{if info.version, do: " #{info.version}", else: ""}"

    lines =
      [title, String.duplicate("-", String.length(title))] ++
        optional_line(Map.get(info, :source_label), Map.get(info, :source)) ++
        optional_line("Tag", Map.get(info, :tag)) ++
        optional_line("Commit", Map.get(info, :revision)) ++
        optional_line("Sparse checkout", Map.get(info, :sparse)) ++
        optional_line("Checkout", Map.get(info, :checkout)) ++
        application_lines(Map.get(info, :mix_app), Map.get(info, :compile)) ++
        optional_line("Hex", info.pkg_url) ++
        optional_line("Doc", info.docs_url) ++
        Enum.map(sorted_links(info.links), fn {label, url} -> "#{label}: #{url}" end) ++
        optional_line("Description", info.description) ++
        optional_line("Path", info.path) ++
        optional_line("Source type", Map.get(info, :source_type)) ++
        dependency_lines(info.children)

    Enum.join(lines, "\n")
  end

  defp optional_line(_label, nil), do: []
  defp optional_line(label, value), do: ["#{label}: #{value}"]

  defp application_lines(false, compile),
    do: ["Mix application: no", "Compile: #{inspect(compile)}"]

  defp application_lines(true, compile),
    do: ["Mix application: yes", "Compile: #{inspect(compile)}"]

  defp application_lines(_app, _compile), do: []

  defp dependency_lines(nil), do: []

  defp dependency_lines(children) do
    ["", "Dependencies (#{length(children)}):"] ++
      Enum.flat_map(children, fn child ->
        ["- #{child.app}  #{child.pkg_url}  #{child.version}"]
      end)
  end

  defp sorted_links(links) do
    links
    |> Enum.reject(fn {_label, url} -> is_nil(url) or url == "" end)
    |> Enum.sort_by(fn {label, _url} -> label end)
  end

  defp print_dep_info({:ok, info}), do: Mix.shell().info(format_dep_info(info))
  defp print_dep_info({:error, message}), do: Mix.shell().error(message)
end
