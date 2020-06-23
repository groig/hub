defmodule Channel do
  def make do
    spawn(&Channel.loop/0)
  end

  def write(channel, val) do
    send(channel, {:write, val, self()})

    receive do
      {:writed, _channel, val} -> val
    end
  end

  def pub(channel, val) do
    send(channel, {:write, val, self()})
  end

  def read(channel) do
    send(channel, {:read, self()})

    receive do
      {:read, _channel, val} -> val
    end
  end

  def loop do
    receive do
      {:read, read_caller} ->
        receive do
          {:write, val, write_caller} ->
            send(read_caller, {:read, self(), val})
            send(write_caller, {:writed, self(), val})
            loop()
        end

      {:write, val, write_caller} ->
        receive do
          {:read, read_caller} ->
            send(read_caller, {:read, self(), val})
            send(write_caller, {:writed, self(), val})
            loop()
        end
    end
  end
end
