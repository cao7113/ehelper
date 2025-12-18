defmodule Ehelper do
  @moduledoc """
  Elixir helpers
  """
  require IEx

  # @compile {:no_warn_undefined, :all}

  require Logger

  @doc """
  Hi test
  """
  def hi, do: :ok

  @doc """
  Ping-pong test
  """
  def ping, do: :pong
  def i, do: info()

  def info do
    [
      elixir_version: System.version(),
      otp_release: System.otp_release(),
      build_info: System.build_info(),
      endiance: System.endianness(),
      self_vm_pid: self(),
      system_os_pid: System.pid(),
      top_apps: Ehelper.App.app_names(sort: false) |> Enum.take(5),
      ehelper: Ehelper.App.spec(:ehelper)
    ]
  end

  @doc """
  Get current dbg backend

  iex --dbg pry
  config :elixir, :dbg_callback, {MyMod, :debug_fun, [:stdio]}
  Application.put_env(:elixir, :dbg_callback, {Macro, :dbg, []})
  if config.pry do
    Application.put_env(:elixir, :dbg_callback, {IEx.Pry, :dbg, []})
  end
  """
  def dbg_backend do
    Application.get_env(:elixir, :dbg_callback)
  end

  @doc """
  Test by by dbg with pry
  - $> iex -S mix
  - iex> break! H, :dbg_demo, 0
  - iex> H.dbg_demo # n to next

  - iex> break! URI, :parse, 1
  - iex> break! URI, :parse, 1

  # or break! URI.parse/1 or break! URI.parse("https" <> _, _)
  - iex> H.dbg_demo
  Break reached: URI.parse/1 (/home/runner/work/elixir/elixir/lib/elixir/lib/uri.ex:792)
  """
  def dbg_demo(url \\ "https://httpbin.org") do
    a = 1
    a = a + 1
    url = URI.parse(url)
    {a, url}
  end

  @doc """
  try dbg pry

  iex -S mix test test/lab/func_test.exs:5 --trace

  debugging
  - https://hexdocs.pm/elixir/debugging.html
  dbg opts
  - https://hexdocs.pm/elixir/Inspect.Opts.html#t:new_opt/0

  #iex>  123 |> dbg(base: :binary)
  #iex>  # 123 #=> 0b1111011

  """
  def pry do
    Logger.info("pry test begin")
    a = 1

    # like dbg to trigger a pry session
    IEx.pry()

    "a"
    |> String.duplicate(5)
    |> String.length()
    |> dbg
    |> IO.puts()

    dbg()

    "Elixir is cool!"
    |> String.trim_trailing("!")
    |> String.split()
    |> List.first()
    |> dbg()

    Logger.info("pry test end")
  end

  ## Application

  def start!(app \\ :ehelper) when is_atom(app), do: Application.ensure_all_started(app)

  def app do
    start!()
    app_of(__MODULE__)
  end

  defdelegate app_of(mod \\ __MODULE__), to: Ehelper.App, as: :get_app

  def sup, do: Process.whereis(Ehelper.Supervisor)

  # utils
  def as_pid(pid), do: Ehelper.Proc.pid(pid)
  def to_pid(pid), do: as_pid(pid)
  def pid_from(pid), do: as_pid(pid)
  def pstate(pid), do: Ehelper.Proc.state(pid)

  ## Utils

  def pp(info, opts \\ []) do
    info |> IO.inspect(limit: :infinity)

    if Keyword.get(opts, :return_nil, true) do
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
