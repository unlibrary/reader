defmodule UnLib.Source do
  @moduledoc """
  Ecto Schema representing a source.

  Unlibrary currently supports these types of feeds:

  - RSS
  - Atom
  - Microformats2

  But support for certain federated/indieweb protocols like microsub is planned and on the roadmap for 2022.
  """
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
