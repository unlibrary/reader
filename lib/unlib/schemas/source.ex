defmodule UnLib.Source do
  use UnLib.Schema
  import Ecto.Changeset

  @derive Jason.Encoder

  typed_schema "sources" do
    field :url, :string
    field :name, :string
    field :icon, :string
    field :type, Ecto.Enum, values: [:rss, :atom, :mf2], default: :rss

    many_to_many :users, UnLib.Account, join_through: "users_sources"
  end

  def changeset(changeset, params \\ %{}) do
    changeset
    |> cast(params, [:url, :name, :icon, :type])
    |> validate_required([:url, :type])
    |> validate_format(:url, ~r/https?:\/\//)
  end
end
