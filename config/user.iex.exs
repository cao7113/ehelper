## iEx session config by ./.iex.exs
# https://hexdocs.pm/iex/IEx.html#module-the-iex-exs-file
# https://hexdocs.pm/iex/IEx.html#module-configuring-the-shell

# v1.18+
IEx.configure(auto_reload: true)
# IEx.configuration
# iex> runtime_info

if Code.ensure_loaded?(Mix) do
  # if in Mix available
  # Mix.Local.append_archives()
  ## Add ehelper into beam code path
  Mix.path_for(:archives)
  |> Path.join("ehelper*/ehelper*")
  |> Path.wildcard()
  |> Enum.map(fn p ->
      ebin_path = Path.join(p, "ebin")
      Code.append_path(ebin_path, cache: true)
  end)
  if Code.ensure_loaded?(Ehelper) do
      Ehelper.start!()
  end

  # :code.get_path()|> Enum.map(&to_string/1)|> Enum.sort()
else
  raise "Mix not loaded"
end

import_if_available Ehelper.Iex
# Eh.hi
alias Ehelper, as: Eh
# alias Ehelper, as: H

## Helps

# Load another ".iex.exs" file
# import_file("~/.iex.exs")
# import_file_if_available("~/.iex.exs")

# Import some module from lib that may not yet have been defined
# import_if_available(MyApp.Mod)

# Print something before the shell starts
# IO.puts("hello world")

# Bind a variable that'll be accessible in the shell
# value = 13
