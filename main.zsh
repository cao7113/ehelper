#export ELIXIR_EDITOR="vim"
# for mix ecto.gen.migration
#export ECTO_EDITOR="vim"
# ref https://gist.github.com/jackhickey/aea3faac46089073f3278efede0ea775
# https://elixirforum.com/t/ecto-editor-with-visual-studio-code/44381/2
#export ECTO_EDITOR="code -rg"

# IO.puts "put me in ~/.iex.exs"

# `iex -S mix` # 进入项目console
# 两次`Ctrl+C` 退出session
# `h # get help`
# `h IEx`
# `h Mix`
# `h Application`

# i IEx
# IEx.module_info()

#export MIX_DEBUG=1

ehelper_rc_script="${(%):-%x}"
ehelper_rc_dir=${ehelper_rc_script:A:h}
function eh(){
  case "$1" in
    up)
      dir=$(pwd)
      cd $ehelper_rc_dir
      #mix do deps.get + compile --force + up
      mix do compile --force + up
      cd $dir > /dev/null
	    ;;
     *)
      cd $ehelper_rc_dir
      ;;
  esac
}
alias ehup="eh up"
alias eup="ehup"

elab_home=$ehelper_rc_dir/..

function elab(){
  case "$1" in
    v|version)
      cd $elab_home && elixir --version && cd - &> /dev/null
	    ;;
    req)
      cd $elab_home/req_client
      ;;
     *)
      cd $elab_home
      ;;
  esac
}

alias el=elixir
# --trace
function i(){
  if [ -f mix.exs ]; then
    iex --erl "-kernel shell_history enabled" -S mix run # --no-start
  else
    iex --erl "-kernel shell_history enabled" 
  fi
}
alias ipry="iex --dbg pry"

eli(){
  case "$1" in
    dry)
      export ELIXIR_CLI_DRY_RUN=1
      echo ELIXIR_CLI_DRY_RUN=$ELIXIR_CLI_DRY_RUN
      ;;
    wet|undry)
      unset ELIXIR_CLI_DRY_RUN
      echo ELIXIR_CLI_DRY_RUN=$ELIXIR_CLI_DRY_RUN
      ;;
    help|h|-h)
      type -f eli
      ;;
    m|mix)
      shift
      ELIXIR_CLI_DRY_RUN=$ELIXIR_CLI_DRY_RUN mix "$@"
      ;;
    i|iex)
      shift
      ELIXIR_CLI_DRY_RUN=$ELIXIR_CLI_DRY_RUN iex "$@"
      ;;
    *)
      ELIXIR_CLI_DRY_RUN=$ELIXIR_CLI_DRY_RUN elixir "$*"
      ;;
 esac
}
alias imix="iex --dbg pry -S mix test --breakpoints --timeout 6000000000"
alias mc="mix compile"
alias mixd="MIX_DEBUG=1 mix"
alias h="mix h"

function ghhexkey(){
  echo gh secret set HEX_API_KEY --body "\$HEX_API_KEY"
  echo gh secret ls
}

alias mixhexpub="mix hex.publish --yes --replace"

# elixir httpc 不支持socks5代理
# 修复 mix phx.gen.release --docker 时的docker info获取问题
# https://github.com/oyyd/http-proxy-to-socks
# npm install -g http-proxy-to-socks
# alias eproxy="hpts -s 127.0.0.1:1080 -p 8080"
# then run below:
# pon 8080 http
