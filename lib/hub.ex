defmodule Hub do
  use Plug.Router
  plug(Plug.Logger)
  plug(:match)
  plug(:dispatch)

  match "/" do
    send_resp(conn, 200, "Send channel id")
  end

  # Default

  get "/:channel_id" do
    get_data(conn, channel_id)
  end

  match "/:channel_id", via: [:post, :patch, :put] do
    post_data(conn, channel_id)
  end

  delete "/:channel_id" do
    delete_channel(conn, channel_id)
  end

  # PubSub

  get "/pubsub/:channel_id" do
    sub_data(conn, channel_id)
  end

  match "/pubsub/:channel_id", via: [:post, :patch, :put] do
    pub_data(conn, channel_id)
  end

  delete "/pubsub/:channel_id" do
    delete_channel(conn, channel_id)
  end

  def init(options) do
    # initialize options
    options
  end

  defp get_data(conn, channel_id) do
    store = Process.whereis(:store)

    data =
      case Store.get(store, channel_id) do
        nil -> Store.put(store, channel_id, Channel.make()) |> Channel.read()
        channel -> Channel.read(channel)
      end

    send_resp(conn, 200, data)
  end


  defp post_data(conn, channel_id) do
    store = Process.whereis(:store)
    {:ok, data, conn} = read_body(conn)

    case Store.get(store, channel_id) do
      nil -> Store.put(store, channel_id, Channel.make()) |> Channel.write(data)
      channel -> Channel.write(channel, data)
    end

    send_resp(conn, 200, channel_id)
  end

  defp pub_data(conn, channel_id) do
    store = Process.whereis(:store)
    {:ok, data, conn} = read_body(conn)

    case Store.get(store, channel_id) do
      nil -> Store.put(store, channel_id, Channel.make()) |> Channel.pub(data)
      channel -> Channel.pub(channel, data)
    end

    send_resp(conn, 201, channel_id)
  end

  defp sub_data(conn, channel_id) do
    store = Process.whereis(:store)

    data =
      case Store.get(store, channel_id) do
        nil -> Store.put(store, channel_id, Channel.make()) |> Channel.sub()
        channel -> Channel.sub(channel)
      end

    send_resp(conn, 200, data)
  end

  defp delete_channel(conn, channel_id) do
    store = Process.whereis(:store)

    case Store.pop(store, channel_id) do
      nil -> send_resp(conn, 404, "channel not found")
      _channel -> send_resp(conn, 200, channel_id <> "deleted")
    end
  end
end
