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
  alias Mix.DepInfo

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
    DepInfo.find_info(dep_name, opts)
  rescue
    error -> {:error, Exception.message(error)}
  end

  def find_dep(dep_name, opts \\ []), do: DepInfo.find(dep_name, opts)

  def format_dep_info(info) do
    title = "#{info.app}#{if info.locked_version, do: " #{info.locked_version}", else: ""}"

    lines =
      [title, String.duplicate("-", String.length(title))] ++
        optional_line(Map.get(info, :source_label), Map.get(info, :source)) ++
        optional_line("Tag", Map.get(info, :tag)) ++
        optional_line("Commit", Map.get(info, :revision)) ++
        optional_line("Sparse checkout", Map.get(info, :sparse)) ++
        optional_line("Checkout", Map.get(info, :checkout)) ++
        application_lines(Map.get(info, :mix_app), Map.get(info, :compile)) ++
        optional_line("Hex", info.pkg_url) ++
        optional_line("Latest", info.latest_version) ++
        optional_line("Doc", info.docs_url) ++
        optional_line("API", info.api_url) ++
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

  defp print_dep_info({:error, app, message}) do
    Mix.shell().error("Unable to load #{app} metadata: #{message}")
  end
end
