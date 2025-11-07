defmodule Ehelper.MixProject do
  use Mix.Project

  @app :ehelper
  @version "0.1.6"
  @source_url "https://github.com/cao7113/ehelper"

  def project do
    [
      app: @app,
      version: @version,
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      name: "ehelper",
      description: "Daily mix helper tasks",
      source_url: @source_url,
      homepage_url: @source_url,
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :inets, :ssl, :crypto],
      mod: {Ehelper.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:hello_libary, "~> 0.1.6"},
      # todo improve here deps
      # for used globally
      # {:git_ops, "~> 2.9", only: [:dev], runtime: false},
      {:git_ops, "~> 2.9"},
      {:ex_doc, "~> 0.39", only: :dev, runtime: false}
    ]
  end

  defp aliases() do
    [
      # install: ["archive.build -o hex.ez", "archive.install hex.ez --force"],
      build: "archive.build -o _build/ehelper-#{@version}.ez",
      install: "archive.install --force _build/ehelper-#{@version}.ez",
      up: "do build + install"
    ]
  end

  def cli do
    [
      # default_task: "eh",
      preferred_envs: [build: :prod, install: :prod, up: :prod]
    ]
  end

  # hex package metadata as https://hex.pm/docs/publish
  def package do
    [
      # This option is only needed when you don't want to use the OTP application name
      licenses: ["Apache-2.0"],
      maintainers: ["cao7113"],
      links: %{
        "GitHub" => @source_url,
        "Docs" => "https://hexdocs.pm/ehelper"
      }
      # files: ["lib", "mix.exs", "README.md"],
    ]
  end
end
