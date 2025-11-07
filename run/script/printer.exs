#!/usr/bin/env elixir

defmodule Printer.CLI do
  @moduledoc """
  synopsis:
    Prints args, possibly multiple times, possibly upper cased.
  usage:
    $ test01 {options} arg1 arg2 ...
  options:
    --upcase      Convert args to upper case.
    --count=n     Print n times.
  """

  def main([]), do: IO.puts(@moduledoc)

  def main([help_opt]) when help_opt == "-h" or help_opt == "--help" or help_opt == "help" do
    IO.puts(@moduledoc)
  end

  def main(args) do
    {opts, cmd_and_args, errors} = parse_args(args)

    case errors do
      [] ->
        process_args(opts, cmd_and_args)

      _ ->
        IO.puts("Bad option:")
        IO.inspect(errors)
        IO.puts(@moduledoc)
    end
  end

  defp parse_args(args) do
    {opts, cmd_and_args, errors} =
      args
      |> OptionParser.parse(strict: [upcase: :boolean, help: :boolean, count: :integer])

    {opts, cmd_and_args, errors}
  end

  defp process_args(opts, args) do
    count = Keyword.get(opts, :count, 1)

    convertfn =
      if Keyword.has_key?(opts, :upcase) do
        fn arg -> String.upcase(arg) end
      else
        fn arg -> arg end
      end

    Stream.iterate(0, &(&1 + 1))
    |> Stream.take(count)
    |> Enum.each(fn idx ->
      if idx > 0 do
        IO.puts("-----------------")
      end

      Stream.with_index(args)
      |> Enum.each(fn {arg, index} ->
        arg1 = convertfn.(arg)
        IO.puts("arg #{index + 1}. #{arg1}")
      end)
    end)
  end
end

System.argv()
|> Printer.CLI.main()
