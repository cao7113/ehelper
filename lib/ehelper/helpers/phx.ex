# if Code.ensure_loaded?(Phoenix), do: :ok

defmodule Ehelper.Phx do
  @moduledoc """
  Phoenix helpers

  - https://hexdocs.pm/phoenix/Phoenix.Debug.html
  """

  @compile {:no_warn_undefined, Phoenix.Debug}

  def hi, do: :ok

  # Phoenix Sockets and Channels process

  @doc """
  Returns a list of all currently connected Phoenix.Socket transport processes.

  [
    %{
      id: "user_socket:3",
      module: SlinkWeb.UserSocket,
      pid: #PID<0.1118.0>
    },
    %{id: nil, module: Phoenix.LiveReloader.Socket, pid: #PID<0.1127.0>}
  ]
  """
  def sockets(opts \\ []) do
    with_reloader = Keyword.get(opts, :with_reloader, false)

    Phoenix.Debug.list_sockets()
    |> Enum.filter(fn %{module: mod} ->
      case mod do
        Phoenix.LiveReloader.Socket -> with_reloader
        _ -> true
      end
    end)
  end

  def socket_of_channel(channel_pid), do: Phoenix.Debug.socket(channel_pid)

  def channels_of_socket(socket_pid \\ rand_socket_pid()) do
    Phoenix.Debug.list_channels(socket_pid)
    |> case do
      {:ok, channels} -> channels
      other -> other
    end
  end

  def rand_socket, do: sockets() |> Enum.random()
  def rand_socket_pid, do: rand_socket() |> Map.get(:pid)
end
