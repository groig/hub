defmodule Hub do
  use Plug.Router
  alias Channel.{PubSub, ProduceConsume, Store}
  plug(Plug.Logger)
  plug(:match)
  plug(:dispatch)

  match "/" do
    send_resp(conn, 200, "Send channel id")
  end

  # Default

  get "/:channel_id" do
    consume(conn, channel_id)
  end

  match "/:channel_id", via: [:post, :patch, :put] do
    produce(conn, channel_id)
  end

  delete "/:channel_id" do
    delete_channel(conn, channel_id)
  end

  # PubSub

  get "/pubsub/:channel_id" do
    subscribe(conn, channel_id)
  end

  match "/pubsub/:channel_id", via: [:post, :patch, :put] do
    publish(conn, channel_id)
  end

  delete "/pubsub/:channel_id" do
    delete_pubsubchannel(conn, channel_id)
  end

  defp produce(conn, channel_id) do
    {:ok, data, conn} = read_body(conn)
    ^data = ProduceConsume.produce(channel_id, data)
    send_resp(conn, 200, channel_id)
  end

  defp consume(conn, channel_id) do
    data = ProduceConsume.consume(channel_id)
    send_resp(conn, 200, data)
  end

  defp delete_channel(conn, channel_id) do
    case Store.delete(channel_id, :prodconchannels) do
      :not_found -> send_resp(conn, 404, "Channel not found")
      :ok -> send_resp(conn, 200, channel_id <> " deleted")
    end
  end

  defp publish(conn, channel_id) do
    {:ok, data, conn} = read_body(conn)
    :ok = PubSub.publish(channel_id, data)
    send_resp(conn, 201, channel_id)
  end

  defp subscribe(conn, channel_id) do
    data = PubSub.subscribe(channel_id)
    send_resp(conn, 200, data)
  end

  defp delete_pubsubchannel(conn, channel_id) do
    case Store.delete(channel_id, :pubsubchannels) do
      :not_found -> send_resp(conn, 404, "Channel not found")
      :ok -> send_resp(conn, 200, channel_id <> " deleted")
    end
  end
end
