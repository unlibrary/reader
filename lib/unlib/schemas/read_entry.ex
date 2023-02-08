defmodule UnLib.ReadEntry do
  @moduledoc """
  Ecto Schema representing a read RSS entry.
  """

  use UnLib.Schema
  import Ecto.Changeset

  @derive Jason.Encoder

  typed_schema "read_entries" do
    field :url, :string

    belongs_to :source, UnLib.Source
    belongs_to :user, UnLib.Account, foreign_key: :user_id
  end

  @spec changeset(Ecto.Changeset.t() | t(), map()) :: Ecto.Changeset.t()
  def changeset(changeset, params \\ %{}) do
    changeset
    |> cast(params, [:url])
    |> validate_required([:url])
  end
end
