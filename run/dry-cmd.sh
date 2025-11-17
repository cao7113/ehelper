#!/bin/sh
set -e # x

echo "## elixir & mix with -s elixir stat_cli"
ELIXIR_CLI_DRY_RUN=1 elixir --version
ELIXIR_CLI_DRY_RUN=1 mix

echo "## iex with -user elixir"
ELIXIR_CLI_DRY_RUN=1 iex
ELIXIR_CLI_DRY_RUN=1 iex -S mix run abc

exit 0

# ## elixir & mix with -s elixir stat_cli
# erl -noshell -elixir_root ~/.asdf/installs/elixir/1.19.2-otp-28/bin/../lib -pa ~/.asdf/installs/elixir/1.19.2-otp-28/bin/../lib/elixir/ebin -s elixir start_cli -extra --version
# erl -noshell -elixir_root ~/.asdf/installs/elixir/1.19.2-otp-28/bin/../lib -pa ~/.asdf/installs/elixir/1.19.2-otp-28/bin/../lib/elixir/ebin -s elixir start_cli -extra ~/.asdf/installs/elixir/1.19.2-otp-28/bin/mix
# ## iex with -user elixir
# erl -noshell -elixir_root ~/.asdf/installs/elixir/1.19.2-otp-28/bin/../lib -pa ~/.asdf/installs/elixir/1.19.2-otp-28/bin/../lib/elixir/ebin -user elixir -extra --no-halt +iex
# erl -noshell -elixir_root ~/.asdf/installs/elixir/1.19.2-otp-28/bin/../lib -pa ~/.asdf/installs/elixir/1.19.2-otp-28/bin/../lib/elixir/ebin -user elixir -extra --no-halt +iex -S mix run abc

# iex 怎么启动的
- by -user elixir
- https://github.com/elixir-lang/elixir/blob/v1.19.2/bin/iex#L38
- :elixir.start()
  - https://github.com/elixir-lang/elixir/blob/v1.19.2/lib/elixir/src/elixir.erl#L178
- :iex.shell()
  - https://github.com/elixir-lang/elixir/blob/v1.19.2/lib/elixir/src/iex.erl#L51
- 'Elixir.IEx.Server':run_from_shell(Opts, MFA)
  - https://github.com/elixir-lang/elixir/blob/v1.19.2/lib/elixir/src/iex.erl#L48C6-L48C23

# elixir 和 mix 启动
- :elixir.start_cli
  - https://github.com/elixir-lang/elixir/blob/v1.19.2/lib/elixir/src/elixir.erl#L181
- 'Elixir.Kernel.CLI':main(init:get_plain_arguments()).
  - https://github.com/elixir-lang/elixir/blob/v1.19.2/lib/elixir/lib/kernel/cli.ex#L29