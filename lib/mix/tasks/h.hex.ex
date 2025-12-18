defmodule Mix.Tasks.H.Hex do
  use Mix.Task

  @shortdoc "Hex info"

  @moduledoc """
  #{@shortdoc}.

  ## See also
  ```
    mix hex
    mix help hex.config
  ```
  """

  @compile {:no_warn_undefined, [Hex]}

  def run(_) do
    if Code.ensure_loaded?(Hex) do
      info = %{
        version: Hex.version(),
        elixir_version: Hex.elixir_version(),
        otp_version: Hex.otp_version()
      }

      Ehelper.pp(info)
    else
      Mix.shell().info("Hex is not available")
    end
  end
end
