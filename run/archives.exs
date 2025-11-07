#!/usr/bin/env mix run

# ref Mix.Local.append_archives()
# https://github.com/elixir-lang/elixir/blob/v1.19.2/lib/mix/lib/mix/local.ex#L41

# def append_archives do
#   for archive <- archives_ebins() do
#     check_elixir_version_in_ebin(archive)
#     Code.append_path(archive, cache: true)
#   end

#   :ok
# end

# path = Mix.path_for(:archives)
# {:ok, archive_names} = File.ls(path)

# paths =
#   archive_names
#   |> Enum.map(fn item ->
#     name =
#       item
#       |> Path.basename()
#       |> Path.rootname(".ez")

#     Path.join([path, name, "ebin"])
#   end)

# paths |> dbg

# ["/Users/rj/.asdf/installs/elixir/1.19.2-otp-28/.mix/archives/hex-2.3.1-otp-28/ebin",
#  "/Users/rj/.asdf/installs/elixir/1.19.2-otp-28/.mix/archives/ehelper-0.1.6/ebin"]

## Add ehelper into beam code path
autoload_archive_paths =
  Mix.path_for(:archives)
  |> Path.join("ehelper*/ehelper*")
  |> Path.wildcard()
  |> Enum.sort()
  |> Enum.map(&Path.join(&1, "ebin"))

autoload_archive_paths |> IO.inspect()

autoload_archive_paths
|> List.first()
|> Code.append_path(cache: true)

# :code.get_path()|> Enum.map(&to_string/1)|> Enum.sort()

:pong == Ehelper.ping()

IO.puts("Ok!")
