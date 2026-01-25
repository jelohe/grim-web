defmodule Grim.Scroll do
  use Ecto.Schema
  import Ecto.Changeset

  schema "scrolls" do
    field :name, :string
    field :content, :string
    belongs_to :user, Grim.Accounts.User
    many_to_many :words, Grim.Word, join_through: "scrolls_tags"

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(scroll, attrs, user_scope) do
    scroll
    |> cast(attrs, [:name, :content])
    |> validate_required([:name])
    |> put_assoc(:user, user_scope.user)
  end
end
