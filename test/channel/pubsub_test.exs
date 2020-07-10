defmodule PubSubTest do
  use ExUnit.Case, async: true
  alias Channel.{Store, PubSub}

  test "Channel.PubSub.publish/2 publishes a message" do
    msg = "a message"
    channel_id = UUID.uuid4()
    assert :ok == PubSub.publish(channel_id, msg)
  end

  test "Channel.PubSub.subscribe/1 subscribes to a channel and receives a message" do
    msg = "a message"
    channel_id = UUID.uuid4()
    sub = Task.async(fn -> PubSub.subscribe(channel_id) end)

    Task.start(fn ->
      :timer.sleep(10)
      PubSub.publish(channel_id, msg)
    end)

    assert msg == Task.await(sub)
  end

  test "Channel.PubSub.subscribe/1 many times and receives a message" do
    msg = "a message"
    channel_id = UUID.uuid4()
    msgs = [msg, msg, msg, msg, msg]
    tasks =
      Enum.map(msgs, fn _ ->
        Task.async(fn ->
          PubSub.subscribe(channel_id)
        end)
      end)

    Task.start(fn ->
      :timer.sleep(10)
      PubSub.publish(channel_id, msg)
    end)

    assert msgs == Enum.map(tasks, fn task -> Task.await(task) end)
  end
end
