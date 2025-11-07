defmodule Ehelper.Httpc do
  @moduledoc """
  Simple HTTP client by wrapping :httpc

  ## httpc

  Great httpc cheatsheet post:  https://elixirforum.com/t/httpc-cheatsheet/50337

  iex>
    :inets.start
    :ssl.start
    :httpc.request 'https://elixir-lang.org'

  """

  require Logger

  @doc """
  Copied from https://github.com/phoenixframework/phoenix/blob/v1.7.6/test/support/http_client.exs

  Performs HTTP Request and returns Response

    * method - The http method, for example :get, :post, :put, etc
    * url - The string url, for example "http://example.com"
    * headers - The map of headers
    * body - The optional string body. If the body is a map, it is converted
      to a URI encoded string of parameters

  ## Examples

      iex> Httpc.request(:get, "http://127.0.0.1", %{})
      {:ok, %Response{..})

      iex> Httpc.request(:post, "http://127.0.0.1", %{}, param1: "val1")
      {:ok, %Response{..})

      iex> Httpc.request(:get, "http://unknownhost", %{}, param1: "val1")
      {:error, ...}

  """
  def request(method, url, headers, body \\ "")

  def request(method, url, headers, body) when is_map(body) do
    request(method, url, headers, URI.encode_query(body))
  end

  def request(method, url, headers, body) do
    url = String.to_charlist(url)
    headers = headers |> Map.put_new("content-type", "text/html")
    ct_type = headers["content-type"] |> String.to_charlist()

    header =
      Enum.map(headers, fn {k, v} ->
        {String.to_charlist(k), String.to_charlist(v)}
      end)

    if proxy = System.get_env("HTTP_PROXY") || System.get_env("http_proxy") do
      Logger.debug("Using HTTP_PROXY: #{proxy}")
      %{host: host, port: port} = URI.parse(proxy)
      :httpc.set_options([{:proxy, {{String.to_charlist(host), port}, []}}])
    end

    if proxy = System.get_env("HTTPS_PROXY") || System.get_env("https_proxy") do
      Logger.debug("Using HTTPS_PROXY: #{proxy}")
      %{host: host, port: port} = URI.parse(proxy)
      :httpc.set_options([{:https_proxy, {{String.to_charlist(host), port}, []}}])
    end

    # Generate a random profile per request to avoid reuse
    # profile = :crypto.strong_rand_bytes(4) |> Base.encode16() |> String.to_atom()
    # {:ok, pid} = :inets.start(:httpc, profile: profile)
    {:ok, pid} = :inets.start(:httpc, profile: nil)

    # todo: use this better
    # ssl: [
    #   verify: :verify_peer,
    #   cacerts: :public_key.cacerts_get(),
    #   customize_hostname_check: [
    #     match_fun: :public_key.pkix_verify_hostname_match_fun(:https)
    #   ]
    # ]
    # ssl:connect("example.net", 443, [
    #     {verify, verify_peer},
    #     {cacerts, public_key:cacerts_get()},
    #     {depth, 3},
    #     {customize_hostname_check, [
    #         {match_fun, public_key:pkix_verify_hostname_match_fun(https)}
    #     ]}
    # ]).

    resp =
      case method do
        :get ->
          :httpc.request(
            :get,
            {url, header},
            [
              ssl: [
                verify: :verify_none
              ]
            ],
            [body_format: :binary],
            pid
          )

        _ ->
          :httpc.request(method, {url, header, ct_type, body}, [], [body_format: :binary], pid)
      end

    :inets.stop(:httpc, pid)
    format_resp(resp)
  end

  defp format_resp({:ok, {{_http, status, _status_phrase}, headers, body}}) do
    {:ok, %{status: status, headers: headers, body: body}}
  end

  defp format_resp({:error, reason}), do: {:error, reason}

  # iex> Httpc.get("https://163.com")
  def get(url), do: request(:get, url, %{})

  # https://github.com/phoenixframework/phoenix/blob/v1.7.6/lib/mix/tasks/phx.gen.release.ex#L235

  # iex>  Httpc.fetch_body!("https://163.com")
  # mix h.fetch https://hub.docker.com/v2/namespaces/hexpm/repositories/elixir/tags\?name\=1.14.5-erlang-25.3-debian-bullseye-
  def fetch_body!(url) do
    url = String.to_charlist(url)
    Logger.debug("Fetching latest image information from #{url}")

    {:ok, _} = Application.ensure_all_started(:inets)
    {:ok, _} = Application.ensure_all_started(:ssl)

    if proxy = System.get_env("HTTP_PROXY") || System.get_env("http_proxy") do
      Logger.debug("Using HTTP_PROXY: #{proxy}")
      %{host: host, port: port} = URI.parse(proxy)
      :httpc.set_options([{:proxy, {{String.to_charlist(host), port}, []}}])
    end

    if proxy = System.get_env("HTTPS_PROXY") || System.get_env("https_proxy") do
      Logger.debug("Using HTTPS_PROXY: #{proxy}")
      %{host: host, port: port} = URI.parse(proxy)
      :httpc.set_options([{:https_proxy, {{String.to_charlist(host), port}, []}}])
    end

    # https://erlef.github.io/security-wg/secure_coding_and_deployment_hardening/inets
    http_options = [
      ssl: [
        verify: :verify_none
      ]
      # ssl: [
      #   verify: :verify_peer,
      #   cacertfile: String.to_charlist(CAStore.file_path()),
      #   depth: 3,
      #   customize_hostname_check: [
      #     match_fun: :public_key.pkix_verify_hostname_match_fun(:https)
      #   ],
      #   versions: protocol_versions()
      # ]
    ]

    case :httpc.request(:get, {url, []}, http_options, body_format: :binary) do
      {:ok, {{_, 200, _}, _headers, body}} -> body
      other -> raise "couldn't fetch #{url}: #{inspect(other)}"
    end
  end

  # defp protocol_versions do
  #   otp_major_vsn = :erlang.system_info(:otp_release) |> List.to_integer()
  #   if otp_major_vsn < 25, do: [:"tlsv1.2"], else: [:"tlsv1.2", :"tlsv1.3"]
  # end

  @doc """
  Get url from httpc, copied from https://github.com/phoenixframework/phoenix/blob/v1.7.7/lib/mix/tasks/phx.gen.release.ex#L192

  iex>  Httpc.fetch_body2!("https://hub.docker.com/v2/namespaces/hexpm/repositories/elixir/tags?name=1.14.5-erlang-25.3-debian-bullseye-")

  mix h.fetch https://hub.docker.com/v2/namespaces/hexpm/repositories/elixir/tags\?name\=1.14.5-erlang-25.3-debian-bullseye- -m 2
  """
  def fetch_body2!(url) do
    url = String.to_charlist(url)
    Logger.debug("Fetching latest image information from #{url}")

    {:ok, _} = Application.ensure_all_started(:inets)
    {:ok, _} = Application.ensure_all_started(:ssl)

    if proxy = System.get_env("HTTP_PROXY") || System.get_env("http_proxy") do
      Logger.debug("Using HTTP_PROXY: #{proxy}")
      %{host: host, port: port} = URI.parse(proxy)
      :httpc.set_options([{:proxy, {{String.to_charlist(host), port}, []}}])
    end

    if proxy = System.get_env("HTTPS_PROXY") || System.get_env("https_proxy") do
      Logger.debug("Using HTTPS_PROXY: #{proxy}")
      %{host: host, port: port} = URI.parse(proxy)
      :httpc.set_options([{:https_proxy, {{String.to_charlist(host), port}, []}}])
    end

    # https://erlef.github.io/security-wg/secure_coding_and_deployment_hardening/inets
    http_options = [
      # ssl: [
      #   verify: :verify_peer,
      #   cacertfile: String.to_charlist(CAStore.file_path()),
      #   depth: 3,
      #   customize_hostname_check: [
      #     match_fun: :public_key.pkix_verify_hostname_match_fun(:https)
      #   ],
      #   versions: protocol_versions()
      # ]

      # 清除对castore的依赖
      ssl: [
        verify: :verify_peer,
        cacerts: :public_key.cacerts_get(),
        depth: 3,
        customize_hostname_check: [
          match_fun: :public_key.pkix_verify_hostname_match_fun(:https)
        ],
        versions: protocol_versions()
      ]
    ]

    case :httpc.request(:get, {url, []}, http_options, body_format: :binary) do
      {:ok, {{_, 200, _}, _headers, body}} -> body
      other -> raise "couldn't fetch #{url}: #{inspect(other)}"
    end
  end

  defp protocol_versions do
    otp_major_vsn = :erlang.system_info(:otp_release) |> List.to_integer()
    if otp_major_vsn < 25, do: [:"tlsv1.2"], else: [:"tlsv1.2", :"tlsv1.3"]
  end
end
