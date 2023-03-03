defmodule Authz.Repo.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create table(:posts) do
      add :title, :string
      add :body, :text
      add :creator_id, references(:users, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:posts, [:creator_id])
  end
end
