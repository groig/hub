defmodule ChannelTest do
  use ExUnit.Case, async: true
  alias Channel.ProduceConsume

  test "Channel.ProduceConsume.consume/1 waits for a message and receives it" do
    msg = "a message"
    channel_id = UUID.uuid4()
    task = Task.async(fn -> ProduceConsume.consume(channel_id) end)
    task1 = Task.async(fn -> ProduceConsume.consume(channel_id) end)

    Task.start(fn ->
      :timer.sleep(50)
      ProduceConsume.produce(channel_id, msg)
    end)

    assert msg == Task.await(task)

    Task.start(fn ->
      :timer.sleep(50)
      ProduceConsume.produce(channel_id, msg)
    end)

    assert msg == Task.await(task1)
  end

  test "Channel.ProduceConsume.produce/2 waits for a consumer" do
    msg = "a message"
    channel_id = UUID.uuid4()
    task = Task.async(fn -> ProduceConsume.produce(channel_id, msg) end)
    task1 = Task.async(fn -> ProduceConsume.produce(channel_id, msg) end)

    Task.start(fn ->
      :timer.sleep(50)
      ProduceConsume.consume(channel_id)
    end)

    assert msg == Task.await(task)

    Task.start(fn ->
      :timer.sleep(50)
      ProduceConsume.consume(channel_id)
    end)

    assert msg == Task.await(task1)
  end
end
