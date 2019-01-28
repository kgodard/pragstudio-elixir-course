defmodule Servy.FourOhFourCounter do

  @name __MODULE__

  def start do
    IO.puts "Starting 404 Counter..."
    pid = spawn(@name, :listen_loop, [%{}])
    Process.register(pid, @name)
    pid
  end

  def bump_count(path) do
    send @name, {self(), :bump_count, path}

    receive do {:response, path_count} -> path_count end
  end

  def get_count(path) do
    send @name, {self(), :get_count, path}

    receive do {:response, path_count} -> path_count end
  end

  def get_counts do
    send @name, {self(), :get_counts}

    receive do {:response, counts} -> counts end
  end

  # Server
  def listen_loop(state) do

    receive do
      {sender, :bump_count, path} ->
        new_state = add_or_increment_key(state, path)
        send sender, {:response, Map.get(new_state, path)}
        listen_loop(new_state)
      {sender, :get_count, path} ->
        send sender, {:response, Map.get(state, path)}
        listen_loop(state)
      {sender, :get_counts} ->
        send sender, {:response, state}
        listen_loop(state)
    end

  end

  defp add_or_increment_key(state_map, key) do
    state_map |> Map.update(key, 1, &(&1 + 1))
  end

end
