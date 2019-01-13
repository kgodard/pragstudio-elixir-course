defmodule Servy.Parser do
  alias Servy.Conv

  def parse(request) do
    [top, params_string] = String.split(request, "\n\n")

    [request_line | header_lines] = String.split(top, "\n")

    [method, path, _] = String.split(request_line, " ")

    IO.inspect header_lines

    headers = parse_headers(header_lines)

    params = parse_params(headers["Content-Type"], params_string)

    %Conv{
      method: method, 
      path: path,
      params: params,
      headers: headers
     }
  end

  def parse_headers(header_lines) do
    header_lines
    |> Enum.reduce(%{}, &extract_key_value/2)
  end

  def extract_key_value(header_line, headers) do
    [key, value] = String.split(header_line, ": ")
    Map.put(headers, key, value)
  end

  def parse_params("application/x-www-form-urlencoded", params_string) do
    params_string |> String.trim |> URI.decode_query
  end

  def parse_params(_, _), do: %{}
end
