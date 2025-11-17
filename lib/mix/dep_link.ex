defmodule Mix.DepLink do
  @moduledoc """
  Manage dep links to local repo code
  """

  alias Mix.RepoInfo

  @default_link_root "deps"
  @default_link_suffix ""

  def hi, do: :hi

  @doc """
  Link dep to a local repo code
  """
  def link_repo(pkg, opts \\ []) do
    {pkg, opts} |> dbg
    link_target = get_link_target(pkg, opts)
    clone_info = RepoInfo.clone_repo(pkg, opts)

    clone_info
    |> case do
      %{
        status: :ok,
        pkg: pkg,
        repo_path: repo_path
      } ->
        if File.exists?(link_target) do
          %{
            kind: :already_existed
          }
        else
          {repo_path, File.exists?(repo_path)} |> dbg
          File.ln_s!(repo_path, link_target)

          %{
            kind: :linked
          }
        end
        |> Map.merge(%{
          status: :ok,
          pkg: pkg,
          link_target: link_target,
          repo_path: repo_path
        })

      _ ->
        clone_info
        |> Map.put(:kind, :clone_repo_failed)
    end
  end

  def get_link_target(pkg, opts \\ []) do
    link_root = get_link_root(opts)
    File.mkdir_p!(link_root)
    suffix = Keyword.get(opts, :link_suffix, @default_link_suffix)
    Path.join(link_root, "#{pkg}#{suffix}")
  end

  def get_link_root(opts \\ []) do
    root = Keyword.get(opts, :link_root, System.get_env("LINK_DEPS_ROOT", @default_link_root))
    if opts[:link_root_expand], do: Path.expand(root), else: root
  end

  def get_links_pattern(opts \\ []) do
    link_root = get_link_root(opts)
    suffix = Keyword.get(opts, :link_suffix, @default_link_suffix)
    Path.join(link_root, "*#{suffix}")
  end

  # https://github.com/hexpm/hex/blob/main/lib/mix/tasks/hex.info.ex#L28
  # https://github.com/hexpm/hex/blob/main/lib/hex/api/package.ex
  def deps_with_local_linking(deps, opts \\ []) do
    deps
    |> deps_normalized()
    |> Enum.map(fn {name, ver, dep_opts} ->
      {local_linking, dep_opts} = Keyword.pop(dep_opts, :local_linking, false)

      if local_linking do
        path = get_link_target(name)

        unless File.exists?(path) do
          link_repo(name, opts)
        end

        dep_opts = Keyword.merge(dep_opts, path: path, override: true)
        {name, ver, dep_opts}
      else
        {name, ver, dep_opts}
      end
    end)
  end

  @doc """
  Get local linking deps only
  """
  def local_linking_deps(deps) do
    deps
    |> deps_normalized()
    |> Enum.filter(fn {_name, _ver, opts} ->
      {local_linking, _opts} = Keyword.pop(opts, :local_linking, false)
      local_linking
    end)
  end

  @doc """
  Get path deps only
  """
  def path_deps(deps) do
    deps
    |> deps_with_local_linking()
    |> Enum.filter(fn {_name, _ver, opts} ->
      Keyword.has_key?(opts, :path)
    end)
  end

  def deps_normalized(deps) do
    deps
    |> Enum.map(fn
      {_name, _ver, opts} = item when is_list(opts) ->
        item

      {name, opts} = _item when is_list(opts) ->
        # todo better???
        {name, ">= 0.0.0", opts}

      {name, ver} when is_binary(ver) ->
        {name, ver, []}

      item ->
        Mix.raise("Unknown dependency format #{inspect(item)}")
    end)
  end
end
