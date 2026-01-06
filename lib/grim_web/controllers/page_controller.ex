defmodule GrimWeb.PageController do
  use GrimWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
