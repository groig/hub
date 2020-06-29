defmodule Hub.Store do
  use Agent

  def start_link(opts) do
    Agent.start_link(fn -> %{} end, opts)
  end

  def get(store, key) do
    Agent.get(store, &Map.get(&1, key))
  end

  def pop(store, key) do
    Agent.get_and_update(store, &Map.pop(&1, key))
  end

  def put(store, key, value) do
    :ok = Agent.update(store, &Map.put(&1, key, value))
    value
  end
end
