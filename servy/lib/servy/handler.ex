defmodule Servy.Handler do

  @moduledoc "Handles HTTP requests"

  @pages_path Path.expand("pages", File.cwd!)

  import Servy.Plugins, only: [rewrite_path: 1, track: 1]
  import Servy.Parser, only: [parse: 1]
  import Servy.FileHandler, only: [handle_file: 2, handle_markdown: 2]
  import Servy.View, only: [render: 3]

  alias Servy.Conv
  alias Servy.BearController
  alias Servy.PledgeController
  alias Servy.FourOhFourCounter, as: Counter

  @doc "transforms request into a response"
  def handle(request) do
    request
    |> parse
    |> rewrite_path
    # |> log
    |> route
    |> track
    |> put_content_length
    |> format_response
  end

  def route(%Conv{ method: "GET", path: "/404s" } = conv) do
    counts = Counter.get_counts()
    %{ conv | status: 200, resp_body: inspect(counts) <> "\n" }
  end

  def route(%Conv{ method: "POST", path: "/pledges" } = conv) do
    PledgeController.create(conv, conv.params)
  end

  def route(%Conv{ method: "GET", path: "/pledges" } = conv) do
    PledgeController.index(conv)
  end

  def route(%Conv{ method: "GET", path: "/pledges/new" } = conv) do
    PledgeController.new(conv)
  end

  def route(%Conv{ method: "GET", path: "/sensors" } = conv) do

    sensor_data = Servy.SensorServer.get_sensor_data()

    render(conv, "sensors.eex",
      where_is_bigfoot: sensor_data.location,
      snapshots: sensor_data.snapshots)
  end

  def route(%Conv{ method: "GET", path: "/kaboom" } = _conv) do
    raise "Kaboom!"
  end

  def route(%Conv{ method: "GET", path: "/hibernate/" <> time } = conv) do
    time |> String.to_integer |> :timer.sleep

    %{ conv | status: 200, resp_body: "Awake!" }
  end

  # name=Baloo&type=Brown
  def route(%Conv{ method: "POST", path: "/bears" } = conv) do
    BearController.create(conv, conv.params)
  end

  def route(%Conv{ method: "GET", path: "/wildthings" } = conv) do
    %{ conv | status: 200, resp_body: "Bears, Lions, Tigers" }
  end

  def route(%Conv{ method: "GET", path: "/bears" } = conv) do
    BearController.index(conv)
  end

  def route(%Conv{ method: "GET", path: "/api/bears" } = conv) do
    Servy.Api.BearController.index(conv)
  end

  def route(%Conv{ method: "POST", path: "/api/bears" } = conv) do
    Servy.Api.BearController.create(conv, conv.params)
  end

  def route(%Conv{ method: "GET", path: "/bears/new" } = conv) do
    @pages_path
    |> Path.join("form.html")
    |> File.read
    |> handle_file(conv)
  end

  def route(%Conv{ method: "GET", path: "/bears/" <> id } = conv) do
    params = Map.put(conv.params, "id", id)
    BearController.show(conv, params)
  end

  def route(%Conv{ method: "DELETE", path: "/bears/" <> id} = conv) do
    params = Map.put(conv.params, "id", id)
    BearController.delete(conv, params)
  end

  def route(%Conv{ method: "GET", path: "/faq" } = conv) do
    @pages_path
    |> Path.join("faq.md")
    |> File.read
    |> handle_markdown(conv)
  end

  def route(%Conv{ method: "GET", path: "/" <> file } = conv) do
    @pages_path
    |> Path.join(file <> ".html")
    |> File.read
    |> handle_file(conv)
  end

  def route(%Conv{ path: path } = conv) do
    %{ conv | status: 404, resp_body: "No #{path} here!" }
  end

  def format_response(%Conv{} = conv) do
    """
    HTTP/1.1 #{Conv.full_status(conv)}\r
    #{format_response_headers(conv)}
    \r
    #{conv.resp_body}
    """
  end

  defp format_response_headers(conv) do
    for {key, value} <- conv.resp_headers do
      "#{key}: #{value}\r"
    end |> Enum.sort |> Enum.reverse |> Enum.join("\n")
  end

  defp put_content_length(conv) do
    headers = Map.put(conv.resp_headers, "Content-Length", String.length(conv.resp_body))
    %{ conv | resp_headers: headers }
  end
end
