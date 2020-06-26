defmodule Channel do
  def make do
    spawn(fn -> Channel.loop([]) end)
  end

  def write(channel, val) do
    send(channel, {:write, val, self()})

    receive do
      {:written, _channel, val} -> val
    end
  end

  def read(channel) do
    send(channel, {:read, self()})

    receive do
      {:read, _channel, val} -> val
    end
  end

  def pub(channel, val) do
    send(channel, {:pub, val})
  end

  def sub(channel) do
    send(channel, {:sub, self()})

    receive do
      {:pub, _channel, val} -> val
    end
  end

  def loop(subs) do
    receive do
      {:read, read_caller} ->
        receive do
          {:write, val, write_caller} ->
            send(read_caller, {:read, self(), val})
            send(write_caller, {:written, self(), val})
            loop(subs)
        end

      {:write, val, write_caller} ->
        receive do
          {:read, read_caller} ->
            send(read_caller, {:read, self(), val})
            send(write_caller, {:written, self(), val})
            loop(subs)
        end

      {:sub, sub_caller} ->
        loop(subs ++ [sub_caller])

      {:pub, val} ->
        subs |> Enum.each(fn sub -> Task.start(fn -> send(sub, {:pub, self(), val}) end) end)

        loop([])
    end
  end
end
