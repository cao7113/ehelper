defmodule Mix.Tasks.H.Docker do
  @moduledoc """
  Get elixir docker image info

  By default, the build uses whatever base image matches your development system’s active versions at generation time.
  extracted and customized from task: mix.gen.release

  ## Links
  - https://hexdocs.pm/phoenix/releases.html#containers
  - https://github.com/phoenixframework/phoenix/blob/main/lib/mix/tasks/phx.gen.release.ex#L366
  """

  use Mix.Task
  require Logger
  alias ReqClient.Channel.Httpc, as: Hc

  @debian "trixie"
  @switches [
    elixir: :string,
    otp: :string,
    debian: :string,
    verbose: :boolean,
    kind: :string
  ]
  @aliases [
    e: :elixir,
    o: :otp,
    d: :debian,
    v: :verbose,
    k: :kind
  ]

  def run(args) do
    {opts, args} = OptionParser.parse!(args, switches: @switches, aliases: @aliases)
    elixir_vsn = opts[:elixir] || elixir_vsn()
    otp_vsn = opts[:otp] || otp_vsn()
    debian_vsn = opts[:debian] || debian_vsn()

    tag_name = "#{elixir_vsn}-erlang-#{otp_vsn}-debian-#{debian_vsn}-"
    url = "https://hub.docker.com/v2/namespaces/hexpm/repositories/elixir/tags?name=#{tag_name}"
    url = List.first(args) || url
    IO.puts("# docker-image-api-url: #{url}")

    hub_url = "https://hub.docker.com/r/hexpm/elixir/tags?name=#{tag_name}"
    IO.puts("# Hub page url: #{hub_url}")

    verbose = Keyword.get(opts, :verbose, false)
    req_opts = [headers: %{"content-type" => "application/json"}, timing: true, debug: verbose]

    result =
      Hc.get!(url, req_opts)
      |> case do
        %{status: st, body: body} = resp when st >= 200 and st < 300 ->
          Map.get(resp, :channel_metadata) |> dbg
          pretty_data(body)

        %{status: status, body: body} ->
          if(String.starts_with?(body, "<!DOCTYPE html>")) do
            write_tmp_file(body)
          end

          raise ~s"""
          # Bad Status: #{status}

          #{body |> inspect}

          unable to fetch supported Docker image for Elixir #{elixir_vsn} and Erlang #{otp_vsn}.
          Please check https://hub.docker.com/r/hexpm/elixir/tags?page=1&name=#{tag_name} \
          for a suitable Elixir version
          """
      end

    result |> dbg
  end

  def elixir_vsn do
    case Version.parse!(System.version()) do
      %{major: major, minor: minor, pre: ["dev"]} -> "#{major}.#{minor - 1}.0"
      _ -> System.version()
    end
  end

  def otp_vsn do
    major = to_string(:erlang.system_info(:otp_release))
    path = Path.join([:code.root_dir(), "releases", major, "OTP_VERSION"])

    case File.read(path) do
      {:ok, content} ->
        String.trim(content)

      {:error, _} ->
        IO.warn("unable to read OTP minor version at #{path}. Falling back to #{major}.0")
        "#{major}.0"
    end
  end

  # https://www.debian.org/releases/
  def debian_vsn do
    @debian
  end

  @doc """
  DockerImage.DataParser.pretty_data()
  """
  def pretty_data(data) when is_map(data) do
    (data["results"] || [])
    |> Enum.filter(fn item ->
      String.ends_with?(item["name"], "-slim") && Enum.count(item["images"]) > 1
    end)
    |> Enum.map(fn item ->
      # elixir_vsn = name |> String.split("-") |> List.first()
      # %{"vsn" => vsn} = Regex.named_captures(~r/.*debian-#{debian_vsn}-(?<vsn>.*)-slim/, name)
      # {:ok, elixir_vsn, vsn}

      images =
        item["images"]
        |> Enum.map(fn img ->
          [
            [img["architecture"], img["variant"]] |> Enum.reject(&is_nil/1) |> Enum.join("/"),
            img["os"]
          ]
          |> Enum.join(" ")
        end)

      item
      |> Map.take(~w[name last_updated])
      |> Map.put("images", images)
    end)
    |> Enum.sort_by(fn it -> it["last_updated"] end, :desc)
  end

  def write_tmp_file(data) do
    tmp_dir = System.tmp_dir!()
    timestamp = DateTime.utc_now() |> DateTime.to_unix()
    random = :rand.uniform(100_000)
    filename = "elixir-docker-image-#{timestamp}-#{random}.html"
    path = Path.join(tmp_dir, filename)
    File.write!(path, data)
    IO.puts("## created tmp file: #{path}")
    path
  end

  def parse(json \\ sample_json())

  def parse(json) when is_binary(json) do
    json |> JSON.decode!()
  end

  def parse(data), do: data

  def sample_json do
    ~s"""
    {
    "count": 6,
    "next": null,
    "previous": null,
    "results": [
        {
            "creator": 9043754,
            "id": 1040899436,
            "images": [
                {
                    "architecture": "arm64",
                    "features": "",
                    "variant": "v8",
                    "digest": "sha256:e0cfc403c1143e2d9a785775986b915880e67230f4a435ce946e3b6dcc256ba5",
                    "os": "linux",
                    "os_features": "",
                    "os_version": null,
                    "size": 84516503,
                    "status": "active",
                    "last_pulled": "2026-01-01T17:14:39.583988587Z",
                    "last_pushed": "2026-01-01T15:44:35.166289511Z"
                }
            ],
            "last_updated": "2026-01-01T15:44:36.795749Z",
            "last_updater": 9043754,
            "last_updater_username": "hexbob",
            "name": "1.19.4-erlang-28.1.1-debian-trixie-20251229-slim",
            "repository": 8323337,
            "full_size": 84516503,
            "v2": true,
            "tag_status": "active",
            "tag_last_pulled": "2026-01-01T17:14:39.583988587Z",
            "tag_last_pushed": "2026-01-01T15:44:36.795749Z",
            "media_type": "application/vnd.docker.distribution.manifest.list.v2+json",
            "content_type": "image",
            "digest": "sha256:3c102af2a10c8b579df483f2f1e476710eb162676fad9d03e0e9b27300afddbd"
        },
        {
            "creator": 9043754,
            "id": 1040894103,
            "images": [
                {
                    "architecture": "arm64",
                    "features": "",
                    "variant": "v8",
                    "digest": "sha256:5ea1eeddf7c0b617dcfa601fa38a106437ba1b180c8216e3367b8c08093217b5",
                    "os": "linux",
                    "os_features": "",
                    "os_version": null,
                    "size": 105597508,
                    "status": "active",
                    "last_pulled": "2026-01-01T17:04:10.695975217Z",
                    "last_pushed": "2026-01-01T15:22:00.868369505Z"
                }
            ],
            "last_updated": "2026-01-01T15:22:02.334914Z",
            "last_updater": 9043754,
            "last_updater_username": "hexbob",
            "name": "1.19.4-erlang-28.1.1-debian-trixie-20251229",
            "repository": 8323337,
            "full_size": 105597508,
            "v2": true,
            "tag_status": "active",
            "tag_last_pulled": "2026-01-01T17:04:10.695975217Z",
            "tag_last_pushed": "2026-01-01T15:22:02.334914Z",
            "media_type": "application/vnd.docker.distribution.manifest.list.v2+json",
            "content_type": "image",
            "digest": "sha256:560ca7ecb558c8063cbdb1386565111771534b4f167c09bba68214cb7624bd5a"
        },
        {
            "creator": 9043754,
            "id": 1026940910,
            "images": [
                {
                    "architecture": "amd64",
                    "features": "",
                    "variant": null,
                    "digest": "sha256:0be831d8e934994cfa95cdd5fe511f817b91b5a5a1bb446e291fa4482586d040",
                    "os": "linux",
                    "os_features": "",
                    "os_version": null,
                    "size": 84211016,
                    "status": "active",
                    "last_pulled": "2025-12-11T14:59:36.600853463Z",
                    "last_pushed": "2025-12-09T02:40:55.419051997Z"
                },
                {
                    "architecture": "arm64",
                    "features": "",
                    "variant": "v8",
                    "digest": "sha256:26942dd29ed56bd2b9f25b919df7b3ec97b29e02d893f0cabe7dc22d1ec50907",
                    "os": "linux",
                    "os_features": "",
                    "os_version": null,
                    "size": 84517548,
                    "status": "active",
                    "last_pulled": "2025-12-09T02:40:56.730914125Z",
                    "last_pushed": "2025-12-09T02:36:16.756679915Z"
                }
            ],
            "last_updated": "2025-12-09T02:40:58.412213Z",
            "last_updater": 9043754,
            "last_updater_username": "hexbob",
            "name": "1.19.4-erlang-28.1.1-debian-trixie-20251208-slim",
            "repository": 8323337,
            "full_size": 84211016,
            "v2": true,
            "tag_status": "active",
            "tag_last_pulled": "2025-12-11T20:29:28.710861764Z",
            "tag_last_pushed": "2025-12-09T02:40:58.412213Z",
            "media_type": "application/vnd.docker.distribution.manifest.list.v2+json",
            "content_type": "image",
            "digest": "sha256:830b0c404538087a721bdcacf2e73bbf405386f8948fcb57716803b54f893a25"
        },
        {
            "creator": 9043754,
            "id": 1026940735,
            "images": [
                {
                    "architecture": "amd64",
                    "features": "",
                    "variant": null,
                    "digest": "sha256:166ad345e4e1c79375f45e7152cd89916f9d3fd2ed1661200218e08fe1375f7b",
                    "os": "linux",
                    "os_features": "",
                    "os_version": null,
                    "size": 105291604,
                    "status": "active",
                    "last_pulled": "2025-12-21T20:04:34.925664996Z",
                    "last_pushed": "2025-12-09T02:40:27.433891682Z"
                },
                {
                    "architecture": "arm64",
                    "features": "",
                    "variant": "v8",
                    "digest": "sha256:1d010e5ecc08f11a7aa133f1b6983232581ec84e94492bca7b66325e2ff35bd3",
                    "os": "linux",
                    "os_features": "",
                    "os_version": null,
                    "size": 105597202,
                    "status": "active",
                    "last_pulled": "2025-12-21T20:04:17.729475569Z",
                    "last_pushed": "2025-12-09T02:36:00.682143266Z"
                }
            ],
            "last_updated": "2025-12-09T02:40:30.258195Z",
            "last_updater": 9043754,
            "last_updater_username": "hexbob",
            "name": "1.19.4-erlang-28.1.1-debian-trixie-20251208",
            "repository": 8323337,
            "full_size": 105291604,
            "v2": true,
            "tag_status": "active",
            "tag_last_pulled": "2025-12-21T20:04:34.925664996Z",
            "tag_last_pushed": "2025-12-09T02:40:30.258195Z",
            "media_type": "application/vnd.docker.distribution.manifest.list.v2+json",
            "content_type": "image",
            "digest": "sha256:9662231052836bac22fe286db05e856c6f55354a70e571a6a2ba5e58f62df4d9"
        },
        {
            "creator": 9043754,
            "id": 1020041494,
            "images": [
                {
                    "architecture": "amd64",
                    "features": "",
                    "variant": null,
                    "digest": "sha256:71182fc7d4d1a862e87d1b0e2d059380d3b9111a95ff60c263adb017e0136bec",
                    "os": "linux",
                    "os_features": "",
                    "os_version": null,
                    "size": 105292296,
                    "status": "active",
                    "last_pulled": "2025-12-31T19:03:38.012976153Z",
                    "last_pushed": "2025-11-27T16:45:43.427154732Z"
                },
                {
                    "architecture": "arm64",
                    "features": "",
                    "variant": "v8",
                    "digest": "sha256:1cf81cccf5181f8416263d095a743818fcccb59353f678035f810493d9816326",
                    "os": "linux",
                    "os_features": "",
                    "os_version": null,
                    "size": 105598818,
                    "status": "inactive",
                    "last_pulled": "2025-11-29T17:06:51.892555647Z",
                    "last_pushed": "2025-11-27T16:45:44.800948673Z"
                }
            ],
            "last_updated": "2025-11-27T16:45:46.302517Z",
            "last_updater": 9043754,
            "last_updater_username": "hexbob",
            "name": "1.19.4-erlang-28.1.1-debian-trixie-20251117",
            "repository": 8323337,
            "full_size": 105292296,
            "v2": true,
            "tag_status": "active",
            "tag_last_pulled": "2026-01-01T15:05:03.126940805Z",
            "tag_last_pushed": "2025-11-27T16:45:46.302517Z",
            "media_type": "application/vnd.docker.distribution.manifest.list.v2+json",
            "content_type": "image",
            "digest": "sha256:249c2a2f1c4496629afcfde77437615d693dd57291fb94518b81bd7e101dbb6d"
        },
        {
            "creator": 9043754,
            "id": 1020041485,
            "images": [
                {
                    "architecture": "amd64",
                    "features": "",
                    "variant": null,
                    "digest": "sha256:e8fafb77823ea4a7ac378c8a9140788bf5b2d0c448e21113f2a0c07812e57931",
                    "os": "linux",
                    "os_features": "",
                    "os_version": null,
                    "size": 84211192,
                    "status": "active",
                    "last_pulled": "2026-01-01T18:47:03.876924982Z",
                    "last_pushed": "2025-11-27T16:45:42.507547737Z"
                },
                {
                    "architecture": "arm64",
                    "features": "",
                    "variant": "v8",
                    "digest": "sha256:aea4823f6597f3b0ff54f89a82bc724ab180107fbb8f0afedfe73ae55f813ee3",
                    "os": "linux",
                    "os_features": "",
                    "os_version": null,
                    "size": 84517742,
                    "status": "active",
                    "last_pulled": "2025-12-29T07:12:27.971335536Z",
                    "last_pushed": "2025-11-27T16:45:43.888568931Z"
                }
            ],
            "last_updated": "2025-11-27T16:45:45.419138Z",
            "last_updater": 9043754,
            "last_updater_username": "hexbob",
            "name": "1.19.4-erlang-28.1.1-debian-trixie-20251117-slim",
            "repository": 8323337,
            "full_size": 84211192,
            "v2": true,
            "tag_status": "active",
            "tag_last_pulled": "2026-01-01T18:47:03.876924982Z",
            "tag_last_pushed": "2025-11-27T16:45:45.419138Z",
            "media_type": "application/vnd.docker.distribution.manifest.list.v2+json",
            "content_type": "image",
            "digest": "sha256:2283d8f320acf4c8e47e835556b47bf9640c6d56d74f7e283952bbce104d3d8e"
        }
    ]
    }
    """
  end
end
