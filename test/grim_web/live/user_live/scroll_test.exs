defmodule GrimWeb.UserLive.ScrollTest do
  use GrimWeb.ConnCase, async: true

  import Grim.AccountsFixtures
  import Phoenix.LiveViewTest

  setup %{conn: conn} do
    user = user_fixture()
    conn = log_in_user(conn, user)
    %{conn: conn, user: user}
  end

  describe "scrolls page" do
    test "renders create button", %{conn: conn} do
      {:ok, _lv, html} = live(conn, ~p"/scrolls")

      assert html =~ "o open e lipu sin"
    end
  end
end
