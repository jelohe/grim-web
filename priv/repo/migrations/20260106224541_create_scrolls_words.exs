defmodule Grim.Repo.Migrations.CreateScrollsWords do
  use Ecto.Migration

  def change do
    create table(:scrolls_words) do
      add :word_id, references(:words)
      add :scroll_id, references(:scrolls)
    end

    create unique_index(:scrolls_words, [:word_id, :scroll_id])
  end
end
