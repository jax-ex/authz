defmodule AuthzWeb.AuthorizationLiveTest do
  use AuthzWeb.ConnCase

  import Phoenix.LiveViewTest
  import Authz.BlogFixtures

  @update_attrs %{body: "some updated body", title: "some updated title"}

  defp create_post(%{user: user}) do
    post = post_fixture(creator_id: user.id)
    %{post: post}
  end

  describe "admin users" do
    setup %{conn: conn} do
      password = valid_user_password()

      {:ok, user} =
        user_fixture(%{password: password})
        |> Ecto.Changeset.change(admin: true)
        |> Authz.Repo.update()

      %{conn: log_in_user(conn, user), user: user, password: password}
    end

    setup [:create_post]

    test "can edit everything", %{conn: conn, post: post} do
      non_admin = user_fixture(%{password: valid_user_password()})
      non_admin_post = post_fixture(creator_id: non_admin.id)

      {:ok, index_live, _html} = live(conn, ~p"/posts")

      # admin can see own edit button
      assert index_live
             |> has_element?("#posts-#{post.id} a", "Edit")

      # admin can see and click other edit button
      assert index_live
             |> has_element?("#posts-#{non_admin_post.id} a", "Edit")

      assert index_live |> element("#posts-#{non_admin_post.id} a", "Edit") |> render_click() =~
               "Edit Post"

      assert_patch(index_live, ~p"/posts/#{non_admin_post}/edit")

      assert index_live
             |> form("#post-form", post: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/posts")
    end

    test "can delete everything", %{conn: conn, post: post} do
      non_admin = user_fixture(%{password: valid_user_password()})
      non_admin_post = post_fixture(creator_id: non_admin.id)

      {:ok, index_live, _html} = live(conn, ~p"/posts")

      # admins can see own delete button
      assert index_live
             |> has_element?("#posts-#{post.id} a", "Delete")

      # admin can see and click other delete buttons
      assert index_live
             |> has_element?("#posts-#{non_admin_post.id} a", "Delete")

      assert index_live |> element("#posts-#{non_admin_post.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#posts-#{non_admin_post.id}")
    end
  end

  describe "users" do
    setup %{conn: conn} do
      password = valid_user_password()

      user = user_fixture(%{password: password})

      %{conn: log_in_user(conn, user), user: user, password: password}
    end

    setup [:create_post]

    test "can edit own posts", %{conn: conn, post: post} do
      {:ok, index_live, _html} = live(conn, ~p"/posts")

      assert index_live |> element("#posts-#{post.id} a", "Edit") |> render_click() =~
               "Edit Post"

      assert_patch(index_live, ~p"/posts/#{post}/edit")

      assert index_live
             |> form("#post-form", post: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/posts")

      html = render(index_live)
      assert html =~ "Post updated successfully"
      assert html =~ "some updated body"
    end

    test "cannot edit others posts", %{conn: conn} do
      another_user = user_fixture(%{password: valid_user_password()})
      another_users_post = post_fixture(creator_id: another_user.id)

      {:ok, index_live, _html} = live(conn, ~p"/posts")

      refute index_live
             |> has_element?("#posts-#{another_users_post.id} a", "Edit")
    end

    test "can delete own posts", %{conn: conn, post: post} do
      {:ok, index_live, _html} = live(conn, ~p"/posts")

      assert index_live |> element("#posts-#{post.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#posts-#{post.id}")
    end

    test "cannot delete others posts", %{conn: conn} do
      another_user = user_fixture(%{password: valid_user_password()})
      another_users_post = post_fixture(creator_id: another_user.id)

      {:ok, index_live, _html} = live(conn, ~p"/posts")

      refute index_live
             |> has_element?("#posts-#{another_users_post.id} a", "Delete")
    end

    test "can nagigate to own post", %{conn: conn, post: post} do
      {:ok, _index_live, _html} = live(conn, ~p"/posts/#{post}/edit")
    end

    test "error when navigating to edit", %{conn: conn} do
      another_user = user_fixture(%{password: valid_user_password()})
      another_users_post = post_fixture(creator_id: another_user.id)

      # Ecto.NoResultsError will result in a 404
      assert_raise Ecto.NoResultsError, fn ->
        {:ok, _index_live, _html} = live(conn, ~p"/posts/#{another_users_post}/edit")
      end

      ## For extra credit do this instead, results in a 403 because :plug_status in struct
      # assert_raise Authz.Policy.AuthorizationError, fn ->
      #   {:ok, _index_live, _html} = live(conn, ~p"/posts/#{another_users_post}/edit")
      # end
    end
  end
end
