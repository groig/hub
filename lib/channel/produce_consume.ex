defmodule Channel.ProduceConsume do
  alias Channel.Store
  @table :prodconchannels

  def produce(channel_id, val) do
    channel = Store.get_channel(__MODULE__, channel_id, @table)
    send(channel, {:write, val, self()})

    receive do
      {:written, _channel, val} -> val
    end
  end

  def consume(channel_id) do
    channel = Store.get_channel(__MODULE__, channel_id, @table)
    send(channel, {:read, self()})

    receive do
      {:read, _channel, val} -> val
    end
  end

  def make do
    spawn(&Channel.ProduceConsume.loop/0)
  end

  def loop() do
    receive do
      {:read, read_caller} ->
        receive do
          {:write, val, write_caller} ->
            send(read_caller, {:read, self(), val})
            send(write_caller, {:written, self(), val})
            loop()
        end

      {:write, val, write_caller} ->
        receive do
          {:read, read_caller} ->
            send(read_caller, {:read, self(), val})
            send(write_caller, {:written, self(), val})
            loop()
        end
    end
  end
end
