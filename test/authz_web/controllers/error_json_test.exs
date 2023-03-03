defmodule AuthzWeb.ErrorJSONTest do
  use AuthzWeb.ConnCase, async: true

  test "renders 404" do
    assert AuthzWeb.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert AuthzWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
