defmodule Servy.Timer do
  def remind(msg, time) when is_integer(time) do
    spawn(Servy.Timer, :reminder, [msg, time])
  end

  def reminder(msg, time) do
    :timer.sleep(time)
    IO.puts(msg)
  end
end
