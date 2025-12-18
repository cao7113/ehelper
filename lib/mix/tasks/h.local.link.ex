defmodule Mix.Tasks.H.Local.Link do
  @shortdoc "Generate deps local-linking template"

  @moduledoc """
  #{@shortdoc}.

  Generate template content to copy into your mix.exs file
  """

  use Mix.Task

  # todo use

  @impl true
  def run(_args) do
    shell = Mix.shell()
    content = Mix.Template.eval_template("local.linking.eex", [])
    shell.info(content)

    shell.info(~S"""
    # Replace `deps: deps()`, with below in def project() in mix.exs
    # deps: env_deps(Mix.env()),
    """)
  end
end
