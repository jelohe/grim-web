defmodule Grim.Repo do
  use Ecto.Repo,
    otp_app: :grim,
    adapter: Ecto.Adapters.Postgres
end
