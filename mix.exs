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
      deps: deps_with_linking_path(),
      # deps: deps(),
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
      extra_applications: [:logger],
      mod: {Ehelper.Application, []},
      env: [
        # here config go into ebin/ehelper.app file, can be configured by config/*.exs
        test: :test_value_from_mix_file_application_func_env_key
      ]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:hello_libary, "~> 0.1.6"},
      {:git_ops, "~> 2.9", only: [:dev], runtime: false, local_linking: true},
      {:ex_doc, "~> 0.39", only: :dev, runtime: false}
    ]
  end

  ## Support deps local-linking
  def raw_deps, do: deps()

  def deps_with_linking_path(deps \\ deps()) do
    # Mix.Local.append_archives()
    # paths = :code.get_path() |> Enum.sort(); paths|>dbg

    Mix.DepLink
    |> Code.ensure_loaded()
    |> case do
      {:module, _} ->
        deps
        |> Mix.DepLink.deps_with_local_linking()

      {:error, reason} ->
        if Mix.env() in [:dev, :test] do
          Mix.shell().error(
            "Not found Mix.DepLink because: #{reason |> inspect}, please run: mix archive.install hex ehelper first!"
          )
        else
          :ok
        end
    end
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

  defp hello(_) do
    Mix.shell().info("Hello world")
  end

  # defp paid_task(_) do
  #   Mix.Task.run("paid.task", [
  #     "first_arg",
  #     "second_arg",
  #     "--license-key",
  #     System.fetch_env!("SOME_LICENSE_KEY")
  #   ])
  # end
end
