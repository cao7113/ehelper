defmodule Mix.Tasks.H.Repo.Clone do
  @shortdoc "Clone dep code into local repository _repos/"

  @moduledoc """
  #{@shortdoc}.

  support clone multiple repositories at once, eg. `mix h.repo.clone phoenix ecto`
  """

  use Mix.Task
  alias Mix.RepoInfo

  @switches [
    depth: :integer
  ]

  @aliases [
    d: :depth
  ]

  @impl true
  def run(args) do
    {opts, args, _error} = OptionParser.parse(args, switches: @switches, aliases: @aliases)
    shell = Mix.shell()

    {ok_items, err_items} =
      args
      |> Enum.map(fn pkg ->
        Task.async(fn ->
          pkg = pkg |> String.trim()
          RepoInfo.clone_repo(pkg, opts)
        end)
      end)
      |> Task.await_many(300_000)
      |> Enum.split_with(fn info ->
        info[:status] == :ok
      end)

    unless Enum.empty?(err_items) do
      shell.info("\n## Err repositories:")

      Enum.each(err_items, fn info ->
        shell.error("!x! #{info[:pkg]}: #{info[:reason]}")
      end)
    end

    shell.info("\n## Ok repositories:")

    Enum.each(ok_items, fn info ->
      shell.info("-- #{info[:pkg]}: #{info[:kind]} #{info[:hub_url]} #{info[:repo_path]}")
    end)

    """

    ## Hints:
    # get more commits: git fetch --depth 50
    # get latest tag:   git tag --sort=-v:refname | head -n 1

    """
    |> shell.info()
  end
end
