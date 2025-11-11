defmodule Ehelper do
  def hi, do: :ok
  def ping, do: :pong
  def i, do: info()

  def info do
    %{
      version: System.version(),
      build_info: System.build_info(),
      otp_release: System.otp_release(),
      endiance: System.endianness(),
      time: System.system_time(),
      system_os_pid: System.pid(),
      self_vm_pid: self(),
      top_started_apps: Ehelper.App.app_names() |> Enum.take(10)
    }
  end

  ## Application

  def start!(app \\ :ehelper) when is_atom(app), do: Application.ensure_all_started(app)

  def app do
    start!()
    app_of(__MODULE__)
  end

  defdelegate app_of(mod \\ __MODULE__), to: Ehelper.App, as: :get_app

  def sup, do: Process.whereis(Ehelper.Supervisor)

  ## Utils

  def blanks(n \\ 20) do
    1..n
    |> Enum.each(fn _ ->
      IO.puts("")
    end)
  end

  def pp(info, opts \\ []) do
    info |> IO.inspect(limit: :infinity)

    if Keyword.get(opts, nil, true) do
      nil
    else
      info
    end
  end

  # todo improve
  def pretty_number(n) do
    n
    |> to_string
    |> String.to_charlist()
    |> Enum.chunk_every(3)
    |> Enum.map(&to_string/1)
    |> Enum.join("_")
  end

  def load_json!(file) do
    file
    |> Path.expand()
    |> File.read!()
    # |> Jason.decode!()
    |> JSON.decode!()
  end
end
