defmodule UnLib.Sources do
  @moduledoc """
  Manages sources for an user.
  """

  alias UnLib.{Repo, Source, Account}
  import Ecto.{Changeset, Query}

  @spec new(String.t(), atom(), String.t() | nil) :: {:ok, Source.t()} | {:error, any()}
  def new(url, type, name \\ nil) do
    Source.changeset(%Source{}, %{
      name: name,
      url: url,
      type: type,
      icon: get_icon(url),
      validate_required: true
    })
    |> Repo.insert_or_update()
  end

  defp get_icon(url) do
    %URI{scheme: scheme, host: host} = URI.parse(url)
    "#{scheme}://#{host}/favicon.ico"
  end

  @spec list :: [Source.t()]
  def list do
    Repo.all(Source)
  end

  @spec list(Account.t()) :: [Source.t()]
  def list(account) do
    account.sources
  end

  @spec get_by_url(String.t()) :: {:ok, Source.t()} | {:error, any()}
  def get_by_url(url) do
    Source
    |> where(url: ^url)
    |> Repo.one()
    |> case do
      nil -> {:error, "Source not found"}
      source -> {:ok, source}
    end
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
