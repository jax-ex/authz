defmodule Authz.Blog.Post do
  use Ecto.Schema
  import Ecto.Changeset

  schema "posts" do
    field :body, :string
    field :title, :string

    belongs_to :creator, Authz.Blog.User

    timestamps()
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:title, :body, :creator_id])
    |> validate_required([:title, :body])
  end
end
