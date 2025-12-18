# iex Helpers

alias Ehelper, as: Eh
alias Ehelper, as: H
import_if_available(Ehelper.Iex)

alias Mix.Project, as: Prj
alias Mix.Dep
# deps = Dep.load_and_cache()

## Net
alias Ehelper.Httpc, as: Httpc
alias Ehelper.Httpc, as: Hc

# if Mix available
# Mix.Local.append_archives()
