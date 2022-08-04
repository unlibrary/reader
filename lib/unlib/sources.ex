defmodule UnLib.Sources do
  @moduledoc """
  Manages sources for an user.
  """

  alias UnLib.{Repo, Source, Account}
  import Ecto.Changeset

  @spec new(String.t(), atom(), String.t() | nil) :: Source.t()
  def new(url, type, name \\ nil) do
    Source.changeset(%Source{}, %{
      name: name,
      url: url,
      type: type,
      icon: "https://#{url}/favicon.ico",
      validate_required: true
    })
    |> Repo.insert_or_update()
  end

  @spec add(Source.t(), Account.t()) :: {:ok, Account.t()} | {:error, any()}
  def add(source, user) do
    sources = user.sources

    if source not in sources do
      user
      |> change()
      |> put_assoc(:sources, sources ++ [source])
      |> Repo.insert_or_update()
    end
  end

  @spec remove(Source.t(), Account.t()) :: {:ok, Account.t()} | {:error, any()}
  def remove(source, user) do
    sources = user.sources

    if source in sources do
      user
      |> change()
      |> put_assoc(:sources, sources -- [source])
      |> Repo.insert_or_update()
    end
  end
end
