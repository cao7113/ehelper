import Config

if config_env() == :dev do
  import_config("git_ops.exs")
end
