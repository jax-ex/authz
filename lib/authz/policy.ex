defmodule Authz.Policy do
  alias Authz.Blog.User

  defmodule AuthorizationError do
    defexception [:message, plug_status: 403]
  end

  def authorize(%User{admin: true}, _action, resource), do: ok(resource)
  def authorize(%User{}, _action, _resource), do: error("Not Authorized")

  def authorize!(user, action, resource) do
    case authorize(user, action, resource) do
      {:ok, resource} -> {:ok, resource}
      {:error, message} -> raise AuthorizationError, message
    end
  end

  def can?(user, action, resource) do
    case authorize(user, action, resource) do
      {:ok, _resource} -> true
      {:error, _message} -> false
    end
  end

  defp ok(resource), do: {:ok, resource}
  defp error(message), do: {:error, message}
end
