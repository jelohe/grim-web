defmodule GrimWeb.PageController do
  use GrimWeb, :controller

  def home(%{assigns: %{current_scope: %{user: _user}}} = conn, _params) do
    redirect(conn, to: "/scrolls")
  end

  def home(conn, _params) do
    render(conn, :home)
  end
end
