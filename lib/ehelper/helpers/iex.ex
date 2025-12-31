defmodule Ehelper.Iex do
  @moduledoc """
  Some improved iex shortcuts

  iex> apps # show started apps
  iex> ri   # runtime_info
  iex> rc   # recompile
  iex> pp <large_obj>
  iex> cwd
  """

  defdelegate rc(options \\ []), to: IEx.Helpers, as: :recompile

  defdelegate ri, to: IEx.Helpers, as: :runtime_info
  # iex> ri :applications
  defdelegate ri(topic), to: IEx.Helpers, as: :runtime_info
  # https://github.com/ferd/recon
  @runtime_topics [:system, :memory, :limits, :applications, :allocators]
  def runtime_topics, do: @runtime_topics
  def apps, do: IEx.Helpers.runtime_info(:applications)

  # iex>  pinfo H.Counter
  def pinfo(pid), do: Ehelper.Proc.info(pid)
  def pstate(pid), do: Ehelper.Proc.state(pid)
  defdelegate pstatus(pid), to: Ehelper.Proc, as: :status
  defdelegate alive?(pid), to: Ehelper.Proc
  def as_pid(pid), do: Ehelper.Proc.pid(pid)
  def dict(pid), do: Ehelper.Proc.dict(pid)
  def mailbox(pid), do: Ehelper.Proc.mailbox(pid)
  def msgbox(pid), do: Ehelper.Proc.msgbox(pid)

  def cwd, do: IEx.Helpers.pwd()
  def puts(device \\ :stdio, s), do: IO.puts(device, s)

  def pp(o), do: Ehelper.pp(o)

  @compile {:no_warn_undefined, :observer}
  @doc """
  Observer debug tool

  - https://hexdocs.pm/elixir/debugging.html#observer

  Mix.ensure_application!(:wx)             # Not necessary on Erlang/OTP 27+
  Mix.ensure_application!(:runtime_tools)  # Not necessary on Erlang/OTP 27+
  Mix.ensure_application!(:observer)
  :observer.start()
  """
  def observer(opts \\ []) do
    if Code.ensure_loaded?(Mix) do
      # Mix.State.builtin_apps()
      Mix.ensure_application!(:observer)
      Application.ensure_loaded(:observer)

      start = Keyword.get(opts, :start, true)

      if start do
        :observer.start()
      else
        Application.get_application(:observer)
      end
    else
      {:error, :mix_not_found}
    end
  end

  def ob(opts \\ []), do: observer(opts)

  @doc """
  Output some blanks, like: IEx.Helpers.clear()
  """
  def blanks(n \\ 10) do
    "\n"
    |> String.duplicate(n)
    |> IO.puts()
  end

  ## IEx related process

  def iex_info do
    ([IEx.Supervisor] ++
       [IEx.Config, IEx.Broker, IEx.Pry])
    |> Enum.into(%{}, fn m ->
      {m, Process.whereis(m)}
    end)
    |> Map.merge(%{
      evalator: iex_elevator_pid(),
      server: iex_server_pid()
    })
  end

  def iex_elevator_pid do
    Process.list()
    |> Enum.find(fn pid ->
      case Process.info(pid, :dictionary) do
        {:dictionary, dict} -> dict |> Keyword.has_key?(:iex_evaluator)
        _ -> false
      end
    end)
  end

  # this is elevator parent, can have more elevators
  def iex_server_pid do
    Process.list()
    |> Enum.find(fn pid ->
      case Process.info(pid, :dictionary) do
        {:dictionary, dict} -> dict |> Keyword.has_key?(:evaluator)
        _ -> false
      end
    end)
  end
end
