defmodule Ehelper.Timer do
  @moduledoc """
  - https://www.erlang.org/doc/apps/stdlib/timer.html
  """

  require Logger

  @doc """

  pos_integer() | second | millisecond | microsecond | nanosecond | native | perf_counter |
  erlang:convert_time_unit(1, second, native)
  - https://hexdocs.pm/elixir/System.html#convert_time_unit/3
  - https://www.erlang.org/doc/apps/erts/erlang#t:time_unit/0
  """
  def tc(fun, args \\ [], opts \\ []) when is_function(fun) do
    time_unit = Keyword.get(opts, :time_unit, :millisecond)
    {time, result} = :timer.tc(fun, args, time_unit)
    log_level_or_false = Keyword.get(opts, :log, :info)

    ms = System.convert_time_unit(time, time_unit, :millisecond)

    if log_level_or_false do
      Logger.log(log_level_or_false, "taken #{ms} ms")
    end

    %{
      time_in_ms: ms,
      time: time,
      time_unit: time_unit,
      result: result
    }
  end

  def test(opts \\ []) do
    tc(
      fn ->
        Process.sleep(100)
        :mock
      end,
      [],
      opts
    )
  end
end
