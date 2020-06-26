defmodule PubSubChannel do
  def make do
    spawn(fn -> PubSubChannel.loop([]) end)
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
      {:sub, sub_caller} ->
        loop(subs ++ [sub_caller])

      {:pub, val} ->
        subs |> Enum.each(fn sub -> Task.start(fn -> send(sub, {:pub, self(), val}) end) end)

        loop([])
    end
  end
end
