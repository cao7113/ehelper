defmodule Ehelper.File do
  @moduledoc """
  File helpers

  $> gdu -b
  $> du -hs
  """

  require Logger

  def is_link?(path) do
    File.lstat(path)
    |> case do
      {:ok, %File.Stat{type: :symlink}} -> true
      _ -> false
    end
  end

  def du_ksize(path) do
    # System.cmd("du", ["-hs", path])
    {info, 0} = System.shell("du -sk #{path}")

    info
    |> String.split("\t", parts: 2)
    |> List.first()
    |> String.to_integer()
  end

  @doc """
  Get directory size in bytes
  """
  def directory_size(path) do
    path = Path.expand(path)
    stat = File.stat!(path)
    file_size(stat, path)
  end

  def file_size(%File.Stat{type: :regular, size: size} = _stat, _file), do: size

  def file_size(%File.Stat{type: :directory, size: _size} = _stat, dir) do
    Path.wildcard(Path.join(dir, "*"))
    |> Enum.reduce(0, fn path, acc ->
      case File.stat(path) do
        {:ok, stat} ->
          acc + file_size(stat, path)

        {:error, reason} ->
          raise "File.stat error #{reason |> inspect} for file: #{path}"
          Logger.warning("File.stat error #{reason |> inspect} for file: #{path}")
          acc
      end
    end)
  end

  def file_size(stat, file) do
    raise "unknown stat: #{stat |> inspect()} for file: #{file}"
    Logger.warning("unknown stat: #{stat |> inspect()} for file: #{file}")
    0
  end
end
