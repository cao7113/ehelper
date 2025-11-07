defmodule Ehelper do
  def hi do
    # {:ok, Application.get_application(__MODULE__)}
    :ok
  end

  def ping, do: :pong

  def pp(info) do
    info |> IO.inspect(limit: :infinity)
    nil
  end

  def load_json!(file) do
    file
    |> File.read!()
    |> Jason.decode!()
  end
end
