defmodule HttpServerTest do
  use ExUnit.Case

  alias Servy.HttpServer

  test "accepts a request on a socket and sends back a response" do
    spawn(HttpServer, :start, [4000])

    url_path = "http://localhost:4000/"

    pages = ["wildthings", "bears", "wildlife", "about"]

    pages
    |> Enum.map(&Task.async(fn -> HTTPoison.get(url_path <> &1) end))
    |> Enum.map(&Task.await/1)
    |> Enum.map(&assert_successful_response/1)
  end

  defp assert_successful_response({:ok, response}) do
    assert response.status_code == 200
  end
end
