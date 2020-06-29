defmodule ChannelTest do
  use ExUnit.Case, async: true

  test "Channel.make/1 creates the channel" do
    channel = Channel.make()
    assert Kernel.is_pid(channel) and Process.alive?(channel)
  end

  test "Channel.read/1 waits for a message and Channel.write/2 sends it" do
    msg = "a message"
    channel = Channel.make()
    task = Task.async(fn -> Channel.read(channel) end)

    Task.start(fn ->
      :timer.sleep(10)
      Channel.write(channel, msg)
    end)

    assert msg == Task.await(task)
  end

  test "Channel.write/2 send a message and Channel.read/1 gets it" do
    msg = "a message"
    channel = Channel.make()
    task = Task.async(fn -> Channel.write(channel, msg) end)

    Task.start(fn ->
      :timer.sleep(10)
      Channel.read(channel)
    end)

    assert msg == Task.await(task)
  end
end
