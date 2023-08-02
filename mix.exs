defmodule Ehelper.MixProject do
  use Mix.Project

  def project do
    [
      app: :ehelper,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:inets, :ssl, :logger, :crypto],
      # extra_applications: extra_applications(Mix.env()) ++ [:logger, :eex, :crypto, :public_key],
      mod: {Ehelper.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      # {:req, "~> 0.3"}
    ]
  end

  defp aliases() do
    [
      up: "cmd MIX_ENV=prod mix archive.install --force"
    ]
  end
end
