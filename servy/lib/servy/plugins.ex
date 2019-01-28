defmodule Servy.Plugins do

  @moduledoc "Plugins for Servy HTTP server"

  # require Logger

  alias Servy.FourOhFourCounter, as: Counter

  alias Servy.Conv

  def track(%Conv{status: 404, path: path} = conv) do
    if Mix.env != :test do
      # Logger.warn "Warning: #{path} is on the loose!"
      Counter.bump_count(path)
      IO.puts "Warning: #{path} is on the loose!"
    end
    conv
  end

  def track(%Conv{} = conv), do: conv

  def rewrite_path(%Conv{path: "/wildlife"} = conv) do
    %{ conv | path: "/wildthings" }
  end

  def rewrite_path(%Conv{path: path} = conv) do
    regex = ~r{\/(?<thing>\w+)\?id=(?<id>\d+)}
    captures = Regex.named_captures(regex, path)
    rewrite_path_captures(conv, captures)
  end

  def rewrite_path_captures(%Conv{} = conv, %{"thing" => thing, "id" => id}) do
    %{ conv | path: "/#{thing}/#{id}" }
  end

  def rewrite_path_captures(%Conv{} = conv, nil), do: conv

  def log(%Conv{} = conv) do
    if Mix.env == :dev do
      IO.inspect conv
    end
    conv
  end

  def emojify(%Conv{ status: 200, resp_body: resp_body } = conv) do
    %{ conv | resp_body: add_emojis(resp_body) }
  end

  def emojify(%Conv{} = conv), do: conv

  def add_emojis(resp_body), do: ":) #{resp_body} :)"
end
