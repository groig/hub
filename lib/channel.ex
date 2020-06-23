defmodule Channel do
  def make do
    spawn(&Channel.loop/0)
  end

  def write(channel, val) do
    send(channel, {:write, val})
  end

  def read(channel) do
    send(channel, {:read, self()})

    receive do
      {:read, _channel, val} -> val
    end
  end

  def loop do
    receive do
      {:read, caller} ->
        receive do
          {:write, val} ->
            send(caller, {:read, self(), val})
            loop()
        end
    end
  end
end
