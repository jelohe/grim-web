defmodule Grim.Repo.Migrations.CreateScrolls do
  use Ecto.Migration

  def change do
    create table(:scrolls) do
      add :name, :string
      add :content, :text
      add :user_id, references(:users, type: :id, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:scrolls, [:user_id])
  end
end
