defmodule Mix.Tasks.H.Gitops do
  @shortdoc "Show git_ops info"
  use Mix.Task

  alias Mix.PkgInfo

  # @requirements ["app.config"]
  # @compile {:no_warn_undefined, GitOps.Config}

  @impl true
  def run(_args) do
    shell = Mix.shell()
    pkg_info = PkgInfo.get_info("igniter", [])
    lver = Version.parse!(pkg_info.latest_version)
    requirement = "~> #{lver.major}.#{lver.minor}"

    info = ~s"""
    # GitOps https://github.com/zachdaniel/git_ops?tab=readme-ov-file#installation-with-igniter

    ## Installation with Igniter

    If Igniter is not already in your project, add it to your deps:

      def deps do
        [
          {:igniter, "#{requirement}", only: [:dev, :test]}
        ]
      end

    Then, run the installer:

      mix igniter.install git_ops

    ## Notices:

    * GitOps has been installed. To create the first release:

        mix git_ops.release --initial

      On subsequent releases, use:

        mix git_ops.release

    ## Patches
      - in mix.exs
        @source_url "https://github.com/cao7113/xxx"
        def project do
          [
            source_url: @source_url,
          ]
        end
      - in git_ops config add below:
        repository_url: Mix.Project.config()[:source_url],

    ## Tasks

      ## Git ops
      ops.up: mix git_ops.release --yes && git push --follow-tags
      prj.info: mix git_ops.project_info
      ops.init: mix git_ops.release --initial

    """

    shell.info(info)

    # if Code.loaded?(GitOps) do
    #   GitOps.Config.types()
    #   |> IO.inspect(label: "git_ops types", pretty: true)
    # else
    #   Mix.shell().error(
    #     "GitOps module not loaded. Please go https://github.com/zachdaniel/git_ops and setup."
    #   )
    # end
  end
end
