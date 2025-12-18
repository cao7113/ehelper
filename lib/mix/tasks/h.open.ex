defmodule Mix.Tasks.H.Open do
  @shortdoc "Open dep resource link in browser"
  @moduledoc """
  #{@shortdoc}.

  This task fetches and displays dependency information from hex.pm.

  ## See also
  ```
    mix hex.docs fetch PACKAGE [VERSION]
    mix hex.docs offline PACKAGE [VERSION]
    mix hex.docs online PACKAGE [VERSION]
  ```
  """

  use Mix.Task
  alias Mix.DepInfo
  @compile {:no_warn_undefined, [Hex.Utils]}

  @switches [
    force: :boolean,
    file_cache: :boolean,
    kind: :string
  ]

  @aliases [
    f: :force,
    c: :file_cache,
    k: :kind
  ]

  @impl true
  def run(args) do
    {opts, args, _error} = OptionParser.parse(args, switches: @switches, aliases: @aliases)
    name = args |> List.first()

    pkg =
      if name do
        name |> String.trim()
      else
        Mix.raise("Require dependency name!")
      end

    info = DepInfo.get_info(pkg, opts)
    github_url = DepInfo.github_url(info)
    docs_url = DepInfo.docs_url(info)
    pkg_url = info.pkg_url
    url = github_url || docs_url || pkg_url

    url =
      case opts[:kind] do
        k when k in ["docs", "doc"] -> docs_url
        _ -> url
      end

    Mix.shell().info("Opening URL: #{url}")
    Hex.Utils.system_open(url)
  end
end
