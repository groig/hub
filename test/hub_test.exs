defmodule HubTest do
  use ExUnit.Case, async: true
  use Plug.Test

  @opts Hub.init([])

  test "asks for an UUID" do
    conn = conn(:get, "/")

    conn = Hub.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == "Send UUID"
  end

  test "validates wron UUID" do
    uuid = "this-is-not-an-uuid"
    conn = conn(:get, "/" <> uuid)

    conn = Hub.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 400
    assert conn.resp_body == "Invalid argument; Not a valid UUID: " <> uuid
  end

  test "returns correct UUID" do
    uuid = UUID.uuid4()
    conn = conn(:get, "/" <> uuid)

    conn = Hub.call(conn, @opts)

    assert conn.state == :sent
    assert conn.status == 200
    assert conn.resp_body == uuid
  end
end
