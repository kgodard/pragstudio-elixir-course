defmodule ImageApi do
  @base_url "https://api.myjson.com/bins/"

  def query(img_id) do
    api_url(img_id)
    |> HTTPoison.get
    |> handle_response
  end

  defp api_url(img_id) do
    @base_url <> URI.encode(img_id)
  end

  defp handle_response({:ok, %{status_code: 200, body: body}}) do
    image_url =
      body
      |> Poison.Parser.parse!
      |> get_in(["image", "image_url"])

    {:ok, image_url}
  end
  defp handle_response({:ok, %{status_code: _status, body: body}}) do
    message =
      body
      |> Poison.Parser.parse!
      |> Map.get("message")

    {:error, message}
  end
  defp handle_response({:error, %{reason: reason}}) do
    {:error, reason}
  end
end
