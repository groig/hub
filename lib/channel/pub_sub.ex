defmodule Channel.PubSub do
  alias Channel.Store
  @table :pubsubchannels

  def publish(channel_id, data) do
    channel = Store.get_channel(__MODULE__, channel_id, @table)
    send(channel, {:publish, data})
    :ok
  end

  def subscribe(channel_id) do
    channel = Store.get_channel(__MODULE__, channel_id, @table)
    send(channel, {:subscribe, self()})

    receive do
      {:publish, data} -> data
    end
  end

  def make do
    spawn(fn -> Channel.PubSub.loop([]) end)
  end

  def loop(subs) do
    receive do
      {:subscribe, sub_caller} ->
        loop(subs ++ [sub_caller])

      {:publish, data} ->
        subs |> Enum.each(fn sub -> send(sub, {:publish, data}) end)

        loop([])
    end
  end
end
