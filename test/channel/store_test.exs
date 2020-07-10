defmodule StoreTest do
  use ExUnit.Case, async: true
  alias Channel.{Store, ProduceConsume, PubSub}

  test "Channel.Store.get_channel/1 gets the correct pubsub channel" do
    channel_id = UUID.uuid4()
    channel = Store.get_channel(PubSub, channel_id, :pubsubchannels)
    assert is_pid(channel)
    assert channel == Store.get_channel(PubSub, channel_id, :pubsubchannels)
  end

  test "Channel.Store.get_channel/1 gets the correct prodcon channel" do
    channel_id = UUID.uuid4()
    channel = Store.get_channel(ProduceConsume, channel_id, :prodconchannels)
    assert is_pid(channel)
    assert channel == Store.get_channel(ProduceConsume, channel_id, :prodconchannels)
  end

  test "Channel.Store.delete/1 deletes the pubsubchannel" do
    channel_id = UUID.uuid4()
    assert :not_found = Store.delete(channel_id, :pubsubchannels)
    Store.get_channel(PubSub, channel_id, :pubsubchannels)
    assert :ok = Store.delete(channel_id, :pubsubchannels)
  end

  test "Channel.Store.delete/1 deletes the prodconchannel" do
    channel_id = UUID.uuid4()
    assert :not_found = Store.delete(channel_id, :prodconchannels)
    Store.get_channel(PubSub, channel_id, :prodconchannels)
    assert :ok = Store.delete(channel_id, :prodconchannels)
  end
end
