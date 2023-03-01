defmodule UnLib.Sources do
  @moduledoc """
  Manages sources for an user.
  """

  alias UnLib.{Repo, Source, Account}
  import Ecto.{Changeset, Query}

  @type type() :: :rss | :atom | :mf2

  @spec new(String.t(), type(), String.t() | nil) :: {:ok, Source.t()} | {:error, any()}
  def new(url, type, name \\ nil) do
    base_source = maybe_get_existing_source(url)

    Source.changeset(base_source, %{
      name: name,
      url: url,
      type: type,
      icon: get_icon(url),
      validate_required: true
    })
    |> Repo.insert_or_update()
  end

  defp maybe_get_existing_source(url) do
    case get_by_url(url) do
      {:ok, source} ->
        source

      {:error, _} ->
        %Source{}
    end
  end

  defp get_icon(url) do
    %URI{scheme: scheme, host: host} = URI.parse(url)
    "#{scheme}://#{host}/favicon.ico"
  end

  @spec list() :: [Source.t()]
  def list do
    Repo.all(Source)
  end

  @spec list(Account.t()) :: [Source.t()]
  def list(account) do
    account
    |> Ecto.assoc(:sources)
    |> preload(:entries)
    |> Repo.all()
  end

  @spec get(Ecto.UUID.t()) :: {:ok, Source.t()} | {:error, any()}
  def get(id) do
    Repo.get(Source, id)
    |> case do
      nil -> {:error, :source_not_found}
      source -> {:ok, Repo.preload(source, :entries)}
    end
  end

  @spec get_by_url(String.t()) :: {:ok, Source.t()} | {:error, any()}
  def get_by_url(url) do
    Source
    |> where(url: ^url)
    |> Repo.one()
    |> case do
      nil -> {:error, :source_not_found}
      source -> {:ok, source}
    end
  end

  @spec add(Source.t(), Account.t()) :: {:ok, Account.t()} | {:error, any()}
  def add(source, user) do
    sources = user.sources

    if source in sources do
      {:error, "already in account"}
    else
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
    else
      {:error, "source not in account"}
    end
  end
end
