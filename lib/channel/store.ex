defmodule Channel.Store do
  def get_channel(module, channel_id, table) do
    new_channel = module.make()
    channel = insert_or_get_channel(channel_id, new_channel, table)

    if new_channel != channel do
      Process.exit(new_channel, :kill)
    end

    channel
  end

  defp insert_or_get_channel(channel_id, new_channel, table) do
    if :ets.insert_new(table, {channel_id, new_channel}) do
      new_channel
    else
      {^channel_id, channel} = hd(:ets.lookup(table, channel_id))
      channel
    end
  end

  def delete(channel_id, table) do
    case :ets.lookup(table, channel_id) do
      [] ->
        :not_found

      _ ->
        :ets.delete(table, channel_id)
        :ok
    end
  end
end
