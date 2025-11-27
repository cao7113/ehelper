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
  def dict(pid), do: Ehelper.Proc.dict(pid)
  def mailbox(pid), do: Ehelper.Proc.mailbox(pid)
  def msgbox(pid), do: Ehelper.Proc.msgbox(pid)

  def cwd, do: IEx.Helpers.pwd()
  def pp(o), do: Ehelper.pp(o)

  @doc """
  Output some blanks, like: IEx.Helpers.clear()
  """
  def blanks(n \\ 20) do
    # 1..n
    # |> Enum.each(fn _ ->
    #   IO.puts("")
    # end)

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
