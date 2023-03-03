defmodule Authz.Repo do
  use Ecto.Repo,
    otp_app: :authz,
    adapter: Ecto.Adapters.Postgres
end
