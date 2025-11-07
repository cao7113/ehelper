defmodule Ehelper.ReleaseInfo do
  @moduledoc """
  Get release info
  """

  @doc """
  Get env-vars info as https://hexdocs.pm/mix/Mix.Tasks.Release.html#module-environment-variables
  """
  def env_vars do
    # The following variables are set early on and can only be read by env.sh and env.bat
    pre_vars = ~w(
      RELEASE_ROOT
      RELEASE_COMMAND
      RELEASE_NAME
      RELEASE_VSN
      RELEASE_PROG
    )

    (pre_vars ++ ~w(
      RELEASE_MODE
      RELEASE_NODE
      RELEASE_COOKIE
      RELEASE_SYS_CONFIG
      RELEASE_VM_ARGS
      RELEASE_REMOTE_VM_ARGS
      RELEASE_TMP
      RELEASE_DISTRIBUTION
      RELEASE_BOOT_SCRIPT
      RELEASE_BOOT_SCRIPT_CLEAN
    ))
    |> Enum.sort()
    |> Enum.map(fn ev ->
      {ev, System.get_env(ev)}
    end)
  end
end
