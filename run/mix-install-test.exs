#!/usr/bin/env elixir

# - https://hexdocs.pm/mix/Mix.html#install/2
# - https://github.com/elixir-lang/elixir/blob/main/lib/mix/lib/mix.ex#L871

# iex --dbg pry run/mix-install-test.exs -v # -f
# --dbg and --dot-iex cannot used at same time???
# --no-start-applications

{opts, _args} =
  OptionParser.parse!(System.argv(),
    switches: [
      verbose: :boolean,
      force: :boolean,
      start_applications: :boolean
    ],
    aliases: [
      v: :verbose,
      f: :force,
      s: :start_applications
    ],
    allow_nonexistent_atoms: true
  )

install_opts = Keyword.take(opts, [:verbose, :force, :start_applications])

{install_timing_ms, :ok} =
  :timer.tc(
    fn ->
      Mix.install([:req_client], install_opts)
    end,
    :millisecond
  )

{
  install_timing_ms,
  Application.started_applications() |> Enum.count(),
  Process.list() |> Enum.count(),
  ReqClient.default_opts(),
  # Mix.install_project_dir(),
  # System.build_info(),
  :end
}
# |> IO.inspect(label: "info")
|> dbg

# Mix.Project.get() |> dbg
if Mix.Project.get() do
  Mix.raise("Mix.install/2 cannot be used inside a Mix project")
end

:ok

# if start_applications = false, only base apps started, not dep-apps
# [
#   {:mix, ~c"mix", ~c"1.19.4"},
#   {:logger, ~c"logger", ~c"1.19.4"},
#   {:iex, ~c"iex", ~c"1.19.4"},
#   {:elixir, ~c"elixir", ~c"1.19.4"},
#   {:compiler, ~c"ERTS  CXC 138 10", ~c"9.0.2"},
#   {:stdlib, ~c"ERTS  CXC 138 10", ~c"7.1"},
#   {:kernel, ~c"ERTS  CXC 138 10", ~c"10.4.1"}
# ]
## only diff ~10ms

# Mix.install_project_dir() #=> "~/Library/Caches/mix/installs/ex-1.19.4-erl-16.1.1/gKmfCdIR_mPnPRT_794Kjw"

# https://www.erlang.org/doc/apps/stdlib/filename.html#basedir/3
# iex(2)> :filename.basedir(:user_cache, ~c"req_client")
# ~c"~/Library/Caches/req_client"

# https://www.erlang.org/doc/apps/erts/erlang.html#system_info/1-system-information
# :erlang.system_info(:otp_release)
# iex(9)> :erlang.system_info(:version)
# ~c"16.1.1"
# iex(10)> System.version()
# "1.19.4"

# After each successful installation, a given set of dependencies is cached so starting another VM and calling Mix.install/2 with the same dependencies will avoid unnecessary downloads and compilations. The location of the cache directory can be controlled using the MIX_INSTALL_DIR environment variable.

# - --force or MIX_INSTALL_FORCE default false

# cache use MIX_INSTALL_DIR env

# The MIX_INSTALL_DIR environment variable configures the directory that caches all Mix.install/2. It defaults to the mix/install folder in the default user cache of your operating system. You can use install_project_dir/0 to access the directory of an existing install (alongside other installs):

# Mix.install_project_dir()

# mix/install folder in the default user cache of your operating system

# Mix.path_for :archives
