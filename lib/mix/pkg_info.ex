defmodule Mix.PkgInfo do
  @moduledoc """
  Hex package metadata and helpers for fetching or interpreting it.

  `Mix.PkgInfo` represents package information returned by the public Hex API.
  Use `fetch/2` to fetch package information directly from Hex.

  The struct fields map to Hex package metadata: `app`, `desc`,
  `latest_version`, `links`, `docs_url`, `pkg_url`, `api_url`, and `downloads`.

    ## Examples

    Fetch the `req` package from Hex:

      iex> {:ok, req} = Mix.PkgInfo.fetch("req")
      iex> req.app
      "req"

    Pass `raw: true` to receive the decoded Hex API response without converting
    it to a `Mix.PkgInfo` struct. Network options such as `timeout`, `debug`,
    and `proxy` are also accepted:

      iex> {:ok, req} = Mix.PkgInfo.fetch("req", raw: true)
      iex> req["name"]
      "req"
      iex> {:ok, req} = Mix.PkgInfo.fetch("req", timeout: 10_000)
      iex> req.app
      "req"

    Use `fetch!/2` when a failed request should raise instead of returning an
    error tuple:

      req = Mix.PkgInfo.fetch!("req")

  """

  defstruct app: nil,
            desc: "",
            latest_version: nil,
            links: %{},
            docs_url: nil,
            pkg_url: nil,
            api_url: nil,
            downloads: %{}

  @type t :: %__MODULE__{
          app: String.t() | nil,
          desc: String.t(),
          latest_version: String.t() | nil,
          links: map(),
          docs_url: String.t() | nil,
          pkg_url: String.t() | nil,
          api_url: String.t() | nil,
          downloads: map()
        }

  @doc """
  Fetch package information directly from Hex, without using the local cache.

  Set `raw: true` to return the decoded Hex API response map instead of a
  `Mix.PkgInfo` struct. This option is also supported by `fetch!/2`.

  Supported options:

    * `:raw` - return the decoded API response map (default: `false`).
    * `:timeout` - request timeout in milliseconds or `:infinity`.
    * `:debug` - enable HTTP client debug logging (default: `false`).
    * `:proxy` - use the proxy configuration from the environment (`:env`), or
      disable proxy use (`false` or `:no`).
  """
  @spec fetch(String.t() | atom(), keyword()) ::
          {:ok, t() | map()} | {:error, term()}
  def fetch(pkg, opts \\ []) do
    {raw?, opts} = Keyword.pop(opts, :raw, false)

    with {:ok, body} <- Mix.PkgInfo.Fetcher.fetch(pkg, opts) do
      if raw?, do: {:ok, body}, else: {:ok, from_api_body(body)}
    end
  end

  @doc "Fetch package information directly from Hex, raising if the request fails."
  @spec fetch!(String.t() | atom(), keyword()) :: t() | map()
  def fetch!(pkg, opts \\ []) do
    case fetch(pkg, opts) do
      {:ok, info} ->
        info

      {:error, reason} ->
        raise "Unable to fetch Hex package #{pkg}: #{inspect(reason)}"
    end
  end

  @doc "Build package information from a decoded Hex API response."
  @spec from_api_body(map()) :: t()
  def from_api_body(body) when is_map(body) do
    meta = Map.get(body, "meta", %{})

    %__MODULE__{
      app: Map.get(body, "name"),
      desc: Map.get(meta, "description", ""),
      latest_version: Map.get(body, "latest_version"),
      links: Map.get(meta, "links", %{}),
      docs_url: Map.get(body, "docs_html_url"),
      pkg_url: Map.get(body, "html_url"),
      api_url: Map.get(body, "url"),
      downloads: Map.get(body, "downloads", %{})
    }
  end

  def github_url(%__MODULE__{links: links}) do
    links["GitHub"] || links["github"]
  end

  def docs_url(%__MODULE__{docs_url: docs_url, links: links}) do
    docs_url || links["Docs"] || links["Changelog"]
  end

  defmodule Fetcher do
    @moduledoc "Fetch package metadata from the public Hex API."

    alias ReqClient.Channel.Httpc

    @api_url "https://hex.pm/api/packages/"

    def fetch(pkg, opts \\ []) do
      url = @api_url <> URI.encode(to_string(pkg))

      http_opts =
        opts
        |> Keyword.take([:timeout, :debug, :proxy])
        |> Keyword.put(:headers, %{"accept" => "application/json"})
        |> Keyword.put(:content_wise_resp_body, true)

      case Httpc.get(url, http_opts) do
        {:ok, %{status: 200, body: body}} when is_map(body) ->
          {:ok, body}

        {:ok, %{status: status, body: body}} ->
          {:error, {:http_status, status, body}}

        {:error, reason} ->
          {:error, reason}
      end
    end
  end
end
