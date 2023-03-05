defmodule Authz.Scope do
  import Ecto.Query

  def scope(_, query) do
    query
  end

  def by_id(scope, id) do
    scope |> where(id: ^id)
  end
end
