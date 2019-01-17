defmodule Servy.FileHandler do
  def handle_markdown({:ok, content}, conv) do
    {:ok, html, _} = Earmark.as_html(content)
    %{ conv | status: 200, resp_body: html }
  end

  def handle_file({:ok, content}, conv) do
    %{ conv | status: 200, resp_body: content }
  end

  def handle_file({:error, :enoent}, conv) do
    %{ conv | status: 404, resp_body: "File not found." }
  end

  def handle_file({:error, reason}, conv) do
    %{ conv | status: 500, resp_body: "File error: #{reason}" }
  end
end
