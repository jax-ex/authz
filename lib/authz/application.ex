defmodule Authz.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      AuthzWeb.Telemetry,
      # Start the Ecto repository
      Authz.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Authz.PubSub},
      # Start Finch
      {Finch, name: Authz.Finch},
      # Start the Endpoint (http/https)
      AuthzWeb.Endpoint
      # Start a worker by calling: Authz.Worker.start_link(arg)
      # {Authz.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Authz.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    AuthzWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
