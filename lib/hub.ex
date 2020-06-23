defmodule Hub do
  import Plug.Conn

  def init(options) do
    # initialize options
    options
  end

  def call(conn, _opts) do
    case conn.request_path do
      "/" -> response(conn, 200, "Send UUID")
      "/" <> uuid -> validate_uuid(uuid, conn)
    end
  end

  defp validate_uuid(uuid, conn) do

    case UUID.info(uuid) do
      {:ok, _} -> process_request(conn, uuid)
      {:error, reason} -> response(conn, 400, reason)
    end
  end

  defp response(conn, code, data) do
    conn |> put_resp_content_type("text/plain") |> send_resp(code, data)
  end

  defp process_request(conn = %Plug.Conn{method: "GET"}, uuid) do
    store = Process.whereis(:store)

    data =
      case Store.get(store, uuid) do
        nil -> Store.put(store, uuid, Channel.make()) |> Channel.read()
        channel -> Channel.read(channel)
      end

    response(conn, 200, data)
  end

  defp process_request(conn = %Plug.Conn{method: "POST"}, uuid) do
    store = Process.whereis(:store)
    {:ok, data, conn} = read_body(conn)

    case Store.get(store, uuid) do
      nil -> Store.put(store, uuid, Channel.make()) |> Channel.write(data)
      channel -> Channel.write(channel, data)
    end

    response(conn, 200, uuid)
  end
end
