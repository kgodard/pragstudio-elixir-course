defmodule Servy.FourOhFourCounter do

  @name :fourohfourcounter

  use GenServer

  def start_link(_arg) do
    IO.puts "Starting 404 Counter..."
    GenServer.start_link(__MODULE__, %{}, name: @name)
  end

  def bump_count(path) do
    GenServer.call @name, {:bump_count, path}
  end

  def get_count(path) do
    GenServer.call @name, {:get_count, path}
  end

  def get_counts do
    GenServer.call @name, :get_counts
  end

  def reset do
    GenServer.cast @name, :reset
  end

  # Server Callbacks

  def handle_cast(:reset, _state) do
    {:noreply, %{}}
  end

  def handle_call({:bump_count, path}, _from, state) do
    new_state = add_or_increment_key(state, path)
    count = Map.get(new_state, path)
    {:reply, count, new_state}
  end

  def handle_call({:get_count, path}, _from, state) do
    count = Map.get(state, path)
    {:reply, count, state}
  end

  def handle_call(:get_counts, _from, state) do
    {:reply, state, state}
  end

  defp add_or_increment_key(state_map, key) do
    state_map |> Map.update(key, 1, &(&1 + 1))
  end

end
