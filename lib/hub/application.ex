defmodule Hub.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Starts a worker by calling: Hub.Worker.start_link(arg)
      # {Hub.Worker, arg}
      {Plug.Cowboy, scheme: :http, plug: Hub, options: [port: 4000]}
    ]

    :ets.new(:prodconchannels, [:public, :named_table, write_concurrency: true, read_concurrency: true])
    :ets.new(:pubsubchannels, [:public, :named_table, write_concurrency: true, read_concurrency: true])

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Hub.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
