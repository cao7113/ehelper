defmodule Mix.Tasks.Eh.Fetch do
  @shortdoc "Fetch url testing"
  use Mix.Task

  @switches [
    method: :string
  ]

  @aliases [
    m: :method
  ]

  @impl true
  def run(args) do
    Application.ensure_all_started(:castore)
    {opts, args} = OptionParser.parse!(args, strict: @switches, aliases: @aliases)
    args |> IO.inspect(label: "args")
    url = Enum.at(args, 0)

    case opts[:method] do
      m when m in ["2", "fetch2"] ->
        Httpc.fetch_body2!(url)

      _ ->
        Httpc.fetch_body!(url)
    end
    |> IO.inspect(label: "response")
  end

  def output(info), do: Mix.shell().info(info |> to_string)
end
