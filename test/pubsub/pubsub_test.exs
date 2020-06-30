defmodule PubSubTest do
  use ExUnit.Case, async: true

  test "PubSubChannel.make/1 creates the pubsub channel" do
    pubsub = PubSubChannel.make()
    assert Kernel.is_pid(pubsub) and Process.alive?(pubsub)
  end

  test "PubSubChannel.pub/2 publishes a message" do
    msg = "a message"
    pubsub = PubSubChannel.make()
    :erlang.trace(pubsub, true, [:receive])
    assert {:pub, msg} == PubSubChannel.pub(pubsub, msg)
    assert_receive({:trace, captured_pid, :receive, captured_message})
    assert captured_pid == pubsub
    assert {:pub, msg} == captured_message
  end

  test "PubSubChannel.sub/1 subscribes to a channel and waits for a message" do
    pubsub = PubSubChannel.make()
    :erlang.trace(pubsub, true, [:receive])
    sub = spawn(fn -> PubSubChannel.sub(pubsub) end)
    assert_receive({:trace, captured_pid, :receive, captured_message})
    assert captured_pid == pubsub
    assert {:sub, sub} == captured_message
  end

  test "PubSubChannel.sub/1 subscribes to a channel and PubSubChannel.pub/2 sends a message" do
    msg = "a message"
    pubsub = PubSubChannel.make()
    task = Task.async(fn -> PubSubChannel.sub(pubsub) end)

    Task.start(fn ->
      :timer.sleep(10)
      PubSubChannel.pub(pubsub, msg)
    end)

    assert msg == Task.await(task)

  end

  test "PubSubChannel.sub/1 subscribes to a channel many times and PubSubChannel.pub/2 sends a message" do
    msg = "a message"
    msgs = [msg, msg, msg, msg, msg]
    pubsub = PubSubChannel.make()

    tasks =
      Enum.map(msgs, fn _ ->
        Task.async(fn ->
          PubSubChannel.sub(pubsub)
        end)
      end)

    Task.start(fn ->
      :timer.sleep(10)
      PubSubChannel.pub(pubsub, msg)
    end)

    assert msgs == Enum.map(tasks, fn task -> Task.await(task) end)
  end
end
