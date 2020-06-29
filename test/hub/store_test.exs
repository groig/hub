defmodule StoreTest do
  alias Hub.Store
  use ExUnit.Case, async: true

  test "stores values by key" do
    {:ok, store} = Store.start_link([])
    assert Store.get(store, "key") == nil
    assert "value" == Store.put(store, "key", "value")
    assert "value" == Store.get(store, "key")
    assert "value" == Store.pop(store, "key")
    assert nil == Store.pop(store, "key")
  end

  test "updates values" do
    {:ok, store} = Store.start_link([])
    assert Store.get(store, "key") == nil
    assert "value" == Store.put(store, "key", "value")
    assert "value" == Store.get(store, "key")
    assert "value1" == Store.put(store, "key", "value1")
    assert "value1" == Store.get(store, "key")
  end
end
