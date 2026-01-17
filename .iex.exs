# iex Helpers

alias Ehelper, as: Eh
alias Ehelper, as: H
import_if_available(Ehelper.Iex)

# Deps
alias Mix.Project, as: Prj
alias Mix.Dep
# deps = Dep.load_and_cache()

# Net
alias ReqClient.Channel.Httpc, as: Hc
