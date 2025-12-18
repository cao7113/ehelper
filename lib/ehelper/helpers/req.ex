defmodule Ehelper.Req do
  @moduledoc """
  Req helpers, Req is a batteries-included HTTP client built on top of Finch and Mint.

  - https://hexdocs.pm/req/readme.html
  """

  @app :req

  def info do
    check!()

    Ehelper.App.spec(@app)
  end

  def check!(mod \\ Req) do
    Code.ensure_loaded!(mod)
  end

  def loaded? do
    Code.ensure_loaded?(Req)
  end
end
