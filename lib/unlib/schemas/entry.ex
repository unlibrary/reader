defmodule UnLib.Entry do
  @moduledoc """
  Ecto Schema representing a RSS entry.
  """

  use UnLib.Schema
  import Ecto.Changeset

  @derive Jason.Encoder

  typed_schema "entries" do
    field :date, :naive_datetime
    field :title, :string
    field :body, :string

    belongs_to :source, UnLib.Source
  end

  def changeset(changeset, params \\ %{}) do
    changeset
    |> cast(params, [:date, :title, :body])
    |> validate_required([:date, :title, :body])
  end
end