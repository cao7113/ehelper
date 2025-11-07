import Config

if config_env() == :dev do
  import_config("git_ops.exs")
end

# config :hello_elixir, :test_conf1, "conf value1"

## config logger app https://hexdocs.pm/logger/1.17.0/Logger.html#module-boot-configuration
# config :logger,
#   handle_otp_reports: true,
#   handle_sasl_reports: true

# # https://hexdocs.pm/logger/1.17.0/Logger.Formatter.html
# config :logger, :default_formatter,
#   format: "[$level] $date $time $message $metadata\n",
#   metadata: [:application, :file]

# # https://www.erlang.org/doc/apps/kernel/logger_std_h.html#content
# config :logger, :default_handler,
#   config: [
#     file: ~c"tmp/log.log",
#     filesync_repeat_interval: 5000,
#     file_check: 5000,
#     max_no_bytes: 10_000_000,
#     max_no_files: 5,
#     compress_on_rotate: true
#   ]
