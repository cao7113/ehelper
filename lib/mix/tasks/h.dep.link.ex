defmodule Mix.Tasks.H.Dep.Link do
  @shortdoc "Link dep to local repository code in _repos/"

  @moduledoc """
  #{@shortdoc}.

  support linking multiple deps at once, eg. `mix h.dep.link phoenix ecto`

  Options:
    * `--link-target-root`, `-r` - root directory to create link targets, default to `deps/`
    * `--link-suffix`, `-s` - suffix for link target names, default to `link`
    * `--depth`, `-d` - git clone depth, default to `20`
  """

  use Mix.Task
  alias Mix.DepLink

  @switches [
    depth: :integer,
    link_root: :string,
    link_suffix: :string
  ]

  @aliases [
    d: :depth,
    r: :link_root,
    s: :link_suffix
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
          DepLink.link_repo(pkg, opts)
        end)
      end)
      |> Task.await_many(300_000)
      |> Enum.split_with(fn info ->
        info[:status] == :ok
      end)

    unless Enum.empty?(err_items) do
      shell.info("\n## Err Linkings:")

      Enum.each(err_items, fn info ->
        shell.error("!x! #{info[:pkg]}: #{info[:reason]}")
      end)
    end

    shell.info("\n## Ok Linkings:")

    Enum.each(ok_items, fn info ->
      shell.info("-- #{info[:pkg]}: #{info[:link_target]} -> #{info[:repo_path]} #{info[:kind]} ")
    end)
  end
end
