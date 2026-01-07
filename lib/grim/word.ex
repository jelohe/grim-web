defmodule Grim.Word do
  use Ecto.Schema
  import Ecto.Changeset

  schema "words" do
    field :name, :string
    belongs_to :user, Grim.Accounts.User
    many_to_many :scrolls, Grim.Scroll, join_through: "scrolls_tags"

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(word, attrs, user_scope) do
    word
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> put_assoc(:user, user_scope.user)
  end
end
