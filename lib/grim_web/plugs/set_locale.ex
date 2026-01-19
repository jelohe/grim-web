defmodule GrimWeb.Plugs.SetLocale do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    locale = get_session(conn, :locale) || "en"
    Gettext.put_locale(GrimWeb.Gettext, locale)
    assign(conn, :locale, locale)
  end
end
