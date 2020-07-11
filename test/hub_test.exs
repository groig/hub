defmodule HubTest do
  use ExUnit.Case, async: true
  use Plug.Test
  alias Channel.{Store, ProduceConsume, PubSub}

  @opts Hub.init([])

  test "asks for a channel id" do
    conn = conn(:get, "/")

    conn = Hub.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "Send channel id"
  end

  test "read and write a value" do
    channel_id = UUID.uuid4()
    conn_get = conn(:get, "/" <> channel_id)
    conn_post = conn(:post, "/" <> channel_id, "message")

    task = Task.async(fn -> Hub.call(conn_get, @opts) end)

    Task.start(fn ->
      :timer.sleep(50)
      Hub.call(conn_post, @opts)
    end)

    conn_get = Task.await(task)

    assert conn_get.state == :sent
    assert conn_get.status == 200
    assert conn_get.resp_body == "message"
  end

  test "write and read a value" do
    channel_id = UUID.uuid4()
    conn_get = conn(:get, "/" <> channel_id)
    conn_post = conn(:post, "/" <> channel_id, "message")

    task = Task.async(fn -> Hub.call(conn_post, @opts) end)

    Task.start(fn ->
      :timer.sleep(50)
      Hub.call(conn_get, @opts)
    end)

    conn_post = Task.await(task)

    assert conn_post.state == :sent
    assert conn_post.status == 200
    assert conn_post.resp_body == channel_id
  end

  test "pub and sub a value" do
    channel_id = UUID.uuid4()
    conn_sub = conn(:get, "/pubsub/" <> channel_id)
    conn_pub = conn(:post, "/pubsub/" <> channel_id, "message")

    task = Task.async(fn -> Hub.call(conn_sub, @opts) end)

    Task.start(fn ->
      :timer.sleep(50)
      Hub.call(conn_pub, @opts)
    end)

    conn_sub = Task.await(task)

    assert conn_sub.state == :sent
    assert conn_sub.status == 200
    assert conn_sub.resp_body == "message"
  end

  test "delete a pubsub channel" do
    channel_id = UUID.uuid4()

    :ets.insert(:pubsubchannels, {channel_id, "fake pid"})

    Store.get_channel(PubSub, channel_id, :pubsubchannels)
    conn = conn(:delete, "/pubsub/" <> channel_id)
    conn = Hub.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == channel_id <> " deleted"

    conn = conn(:delete, "/pubsub/" <> channel_id)

    conn = Hub.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 404
    assert conn.resp_body == "Channel not found"
  end

  test "delete a prodcon channel" do
    channel_id = UUID.uuid4()

    :ets.insert(:prodconchannels, {channel_id, "fake pid"})

    Store.get_channel(ProduceConsume, channel_id, :prodconchannels)
    conn = conn(:delete, "/" <> channel_id)
    conn = Hub.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == channel_id <> " deleted"

    conn = conn(:delete, "/" <> channel_id)

    conn = Hub.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 404
    assert conn.resp_body == "Channel not found"
  end
end
