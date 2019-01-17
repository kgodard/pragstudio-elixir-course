defmodule Servy.Wildthings do
  alias Servy.Bear
  @db_path Path.expand("db", File.cwd!)

  def list_bears do
    filepath = Path.join(@db_path, "bears.json")

    {:ok, json} = File.read(filepath)

    bear_map = Poison.decode!(json, as: %{"bears" => [%Bear{}]})

    bear_map["bears"]
  end

  def get_bear(id) when is_integer(id) do
    Enum.find(list_bears(), fn(b) -> b.id == id end)
  end

  def get_bear(id) when is_binary(id) do
    id |> String.to_integer |> get_bear
  end
end
