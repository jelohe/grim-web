defmodule GrimWeb.ErrorJSONTest do
  use GrimWeb.ConnCase, async: true

  test "renders 404" do
    assert GrimWeb.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert GrimWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
