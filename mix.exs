defmodule Ehelper.MixProject do
  use Mix.Project

  @app :ehelper
  @version "0.2.9"
  @source_url "https://github.com/cao7113/ehelper"

  def project do
    [
      app: @app,
      version: @version,
      elixir: "~> 1.17",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      description: "Daily mix helper tasks",
      package: package(),

      # Docs
      name: "Ehelper",
      source_url: @source_url,
      homepage_url: @source_url,
      docs: &docs/0
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Ehelper.Application, []},
      extra_applications: [:logger, :runtime_tools, :inets, :ssl],
      env: [
        # here config go into ebin/ehelper.app file, can be configured by host-app config/*.exs
        test: :test_from_mix_exs_application_func_env_key
      ]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  # options ref https://hexdocs.pm/mix/Mix.Tasks.Deps.html#module-options
  # mix help deps
  # specifying :decimal is the same as {:decimal, ">= 0.0.0"}
  defp deps do
    [
      {:git_ops, "~> 2.9", only: [:dev], runtime: false,},
      # mix igniter.install git_ops
      {:igniter, "~> 0.7", only: [:dev, :test]},
      {:ex_doc, "~> 0.39", only: :dev, runtime: false}
    ]
  end

  defp aliases() do
    [
      # install: ["archive.build -o _build/ehelper.ez", "archive.install _build/ehelper.ez --force"],
      build: "archive.build -o _build/ehelper-#{@version}.ez",
      install: "archive.install --force _build/ehelper-#{@version}.ez",
      up: "do build + install",
      c: "compile",
      hi: [&hello/1]
    ]
  end

  def cli do
    [
      # default_task: "eh",
      preferred_envs: [build: :prod, install: :prod, up: :prod]
    ]
  end

  defp docs do
    [
      # The main page in the docs
      # main: "MyApp",
      # logo: "path/to/logo.png",
      # extras: ["README.md"]
    ]
  end

  # hex package metadata as https://hex.pm/docs/publish
  def package do
    [
      links: %{
        "GitHub" => @source_url,
        "Docs" => "https://hexdocs.pm/ehelper"
      },
      files: ["lib", "priv", "mix.exs", "mix.lock", "README.md"],
      licenses: ["Apache-2.0"],
      maintainers: ["cao7113"]
    ]
  end

  defp hello(_) do
    Mix.shell().info("Hello world")

    # Mix.Task.run("paid.task", [
    #   "first_arg",
    #   "second_arg",
    #   "--license-key",
    #   System.fetch_env!("SOME_LICENSE_KEY")
    # ])
  end
end
