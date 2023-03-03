# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Authz.Repo.insert!(%Authz.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

Authz.Repo.delete_all(Authz.Blog.User)
Authz.Repo.delete_all(Authz.Blog.Post)

{:ok, admin} =
  Authz.Blog.register_user(%{
    email: "micah@example.com",
    password: "passwordpassword"
  })

admin
|> Ecto.Changeset.change(admin: true)
|> Authz.Repo.update()

{:ok, joe} =
  Authz.Blog.register_user(%{
    email: "joe@example.com",
    password: "passwordpassword"
  })

{:ok, jane} =
  Authz.Blog.register_user(%{
    email: "jane@example.com",
    password: "passwordpassword"
  })

users = [admin, joe, jane]

for _ <- 1..10 do
  user = Enum.random(users)

  Authz.Blog.create_post(%{
    creator_id: user.id,
    body: Faker.Lorem.paragraph(),
    title: Faker.Lorem.sentence()
  })
end
