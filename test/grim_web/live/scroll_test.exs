defmodule GrimWeb.ScrollTest do
  use GrimWeb.ConnCase, async: true

  import Grim.AccountsFixtures
  import Phoenix.LiveViewTest

  setup %{conn: conn} do
    user = user_fixture()
    conn = log_in_user(conn, user)
    %{conn: conn, user: user}
  end

  describe "scrolls page" do
    test "renders a create button", %{conn: conn} do
      {:ok, _lv, html} = live(conn, ~p"/scrolls")

      assert html =~ "New note"
    end

    test "creates a new scroll", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/scrolls")

      lv
      |> form("#scroll-editor", scroll: %{name: "my note", content: "hello"})
      |> render_change()

      assert has_element?(lv, "li", "my note")
    end

    test "updates an existing scroll", %{conn: conn, user: user} do
      %Grim.Scroll{user_id: user.id, name: "old scroll", content: "old text"}
      |> Grim.Repo.insert!()

      {:ok, lv, _html} = live(conn, ~p"/scrolls")

      lv
      |> element("li", "old scroll")
      |> render_click()

      assert has_element?(lv, "li", "old scroll")

      lv
      |> form("#scroll-editor", scroll: %{name: "new scroll", content: "new text"})
      |> render_change()

      assert has_element?(lv, "li", "new scroll")
      refute has_element?(lv, "li", "old scroll")
    end

    test "clicking a scroll loads it into the editor", %{conn: conn, user: user} do
      %Grim.Scroll{
        user_id: user.id,
        name: "existing scroll",
        content: "text content of the existing scroll"
      }
      |> Grim.Repo.insert!()

      {:ok, lv, _html} = live(conn, ~p"/scrolls")

      lv
      |> element("li", "existing scroll")
      |> render_click()

      assert has_element?(lv, "input[value=\"existing scroll\"]")

      assert has_element?(
               lv,
               "textarea",
               "text content of the existing scroll"
             )
    end
  end
end
