defmodule Tunez.Application do
  @moduledoc false

  use Application

  alias AshGraphql.Subscription.Batcher

  @impl Application
  def start(_type, _args) do
    children = [
      TunezWeb.Telemetry,
      Tunez.Repo,
      {DNSCluster, query: Application.get_env(:tunez, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Tunez.PubSub},
      {Finch, name: Tunez.Finch},
      # Start a worker by calling: Tunez.Worker.start_link(arg)
      # {Tunez.Worker, arg},
      # Start to serve requests, typically the last entry
      TunezWeb.Endpoint,
      {Absinthe.Subscription, TunezWeb.Endpoint},
      Batcher,
      {AshAuthentication.Supervisor, [otp_app: :tunez]}
    ]

    opts = [strategy: :one_for_one, name: Tunez.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl Application
  def config_change(changed, _new, removed) do
    TunezWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
