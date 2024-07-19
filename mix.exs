defmodule Ehelper.MixProject do
  use Mix.Project

  @version "0.1.4"

  def project do
    [
      app: :ehelper,
      version: @version,
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      name: "ehelper",
      description: "daily mix helper tasks",
      source_url: "https://github.com/cao7113/ehelper",
      homepage_url: "https://github.com/cao7113/ehelper",
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
      {:ex_doc, "~> 0.34", only: :dev, runtime: false},
      {:git_ops, "~> 2.6", only: [:dev], runtime: false}
    ]
  end

  defp aliases() do
    [
      up: "cmd MIX_ENV=prod mix archive.install --force"
    ]
  end

  # hex package metadata as https://hex.pm/docs/publish
  def package do
    [
      # This option is only needed when you don't want to use the OTP application name
      licenses: ["Apache-2.0"],
      maintainers: ["cao7113"],
      links: %{
        "GitHub" => "https://github.com/cao7113/ehelper",
        "Docs" => "https://hexdocs.pm/ehelper"
      }
      # files: ["lib", "mix.exs", "README.md"],
    ]
  end
end
