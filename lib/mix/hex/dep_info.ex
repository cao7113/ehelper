defmodule Mix.Hex.DepInfo do
  @moduledoc """
  Dep info

  Hex Code  https://github.com/hexpm/hex
  Hex API:  https://hex.pm/api/packages/ecto
  Hex Spec: https://hexdocs.pm/hex_core/readme.html
  """
  @compile {:no_warn_undefined, Hex}
  @compile {:no_warn_undefined, Hex.API.Package}

  def get_info(pkg, opts \\ []) do
    force_fetch = Keyword.get(opts, :force, false)
    cache_path = dep_cache_path(pkg)

    {channel, body} =
      if File.exists?(cache_path) and not force_fetch do
        {:cached, JSON.decode!(File.read!(cache_path))}
      else
        IO.puts("# [#{pkg}] loading pkg info into: #{cache_path}")
        start = DateTime.utc_now()

        # todo 1 only ensure :hex loaded 2 use hex api directly?
        Mix.Local.append_archives()
        Application.ensure_all_started(:hex)

        {:ok, {200, _headers, body}} = Hex.API.Package.get(nil, pkg, nil)
        File.write!(cache_path, JSON.encode!(body))
        du = DateTime.diff(DateTime.utc_now(), start, :millisecond)
        IO.puts("# [#{pkg}] loaded pkg info taken: #{du} ms")
        {:fetched, body}
      end

    body =
      body
      |> Enum.map(fn {k, v} ->
        {k |> String.to_atom(), v}
      end)
      |> Map.new()

    # todo: defstruct?
    %{
      app: body.name,
      desc: body.meta["description"],
      latest_version: body.latest_version,
      links: body.meta["links"],
      docs_url: body.docs_html_url,
      pkg_url: body.html_url,
      api_url: body.url,
      downloads: body.downloads,
      channel: channel
    }
  end

  def dep_cache_path(name) when is_binary(name) do
    Path.join(dep_cache_root(), "#{name}.json")
  end

  def dep_cache_root(opts \\ []) do
    root =
      System.get_env("EHELPER_DEP_INFO_ROOT", "~/.mix.deps.info")
      |> Path.expand()

    mk = Keyword.get(opts, :make_dir, true)
    if mk, do: File.mkdir_p!(root)

    root
  end

  # %{
  #   "configs" => %{
  #     "erlang.mk" => "dep_ehelper = hex 0.1.6",
  #     "mix.exs" => "{:ehelper, \"~> 0.1.6\"}",
  #     "rebar.config" => "{ehelper, \"0.1.6\"}"
  #   },
  #   "docs_html_url" => "https://hexdocs.pm/ehelper/",
  #   "downloads" => %{"all" => 373, "recent" => 69},
  #   "html_url" => "https://hex.pm/packages/ehelper",
  #   "inserted_at" => "2024-06-14T08:50:02Z",
  #   "latest_stable_version" => "0.1.6",
  #   "latest_version" => "0.1.6",
  #   "meta" => %{
  #     "description" => "Daily mix helper tasks",
  #     "licenses" => ["Apache-2.0"],
  #     "links" => %{
  #       "Docs" => "https://hexdocs.pm/ehelper",
  #       "GitHub" => "https://github.com/cao7113/ehelper"
  #     },
  #     "maintainers" => []
  #   },
  #   "name" => "ehelper",
  #   "owners" => [
  #     %{
  #       "email" => "cao7113@hotmail.com",
  #       "url" => "https://hex.pm/api/users/cao7113",
  #       "username" => "cao7113"
  #     }
  #   ],
  #   "releases" => [
  #     %{
  #       "has_docs" => true,
  #       "inserted_at" => "2025-07-16T10:29:57Z",
  #       "url" => "https://hex.pm/api/packages/ehelper/releases/0.1.6",
  #       "version" => "0.1.6"
  #     }
  #   ],
  #   "repository" => "hexpm",
  #   "retirements" => %{},
  #   "updated_at" => "2025-07-16T10:30:00Z",
  #   "url" => "https://hex.pm/api/packages/ehelper"
  # }
end
