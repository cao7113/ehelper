defmodule Mix.RepoInfo do
  @moduledoc """
  Repo info
  """

  alias Mix.DepInfo

  def clone_repo(pkg, opts \\ []) do
    pkg = pkg |> to_string
    repo_path = local_repo_path(pkg, [])
    hub_url = get_github_url(pkg, [])
    depth = Keyword.get(opts, :depth, 20)

    if File.exists?(repo_path) do
      {:ok, :already_existed}
    else
      if hub_url == nil do
        {:error, :no_repo_url}
      else
        cmd = "git clone --depth #{depth} #{hub_url} #{repo_path}"
        {reason, code} = System.shell(cmd)

        if code != 0 do
          {:error, reason}
        else
          {:ok, :cloned}
        end
      end
    end
    |> case do
      {:ok, kind} ->
        %{
          status: :ok,
          kind: kind
        }

      {:error, reason} ->
        %{
          status: :error,
          reason: reason
        }
    end
    |> Map.put(:hub_url, hub_url)
    |> Map.put(:repo_path, repo_path)
    |> Map.put(:pkg, pkg)
  end

  def get_github_url(name, opts \\ []) do
    dep = DepInfo.get_info(name, opts)
    DepInfo.github_url(dep)
  end

  def local_repo_path(name, opts \\ []) do
    root = local_repos_root(opts)
    Path.join(root, name)
  end

  def local_repos_root(opts \\ []) do
    root =
      System.get_env("LOCAL_REPOS_ROOT", "~/dev/_repos/github")
      |> Path.expand()

    mk = Keyword.get(opts, :make_dir, true)
    if mk, do: File.mkdir_p!(root)

    root
  end
end
