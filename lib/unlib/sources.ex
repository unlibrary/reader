defmodule UnLib.Sources do
  @moduledoc """
  Manages sources for an user.

  A source is a feed you follow. Multiple users can follow the same feeds,
  which will be the same source in the database.

  Sources can be created and then added to an account. Sources that aren't added to
  any accounts won't be pulled.

  > Warning:
  > There is one design flaw: if multiple accounts follow the same feed, and
  one user changes its name, it will change for all users.
  """

  alias UnLib.{Repo, Source, Account}
  import Ecto.{Changeset, Query}

  @type type() :: :rss | :atom | :mf2

  @doc """
  Creates a new source.

  Inserts the source if it doesn't exist yet, otherwise
  updates the existing source.
  """
  @spec new(String.t(), type(), String.t() | nil) :: {:ok, Source.t()} | {:error, any()}
  def new(url, type, name \\ nil) do
    base_source = maybe_get_existing_source(url)

    Source.changeset(base_source, %{
      name: name,
      url: url,
      type: type,
      icon: get_icon(url)
    })
    |> Repo.insert_or_update()
  end

  @doc """
  Updates a source.
  """
  @spec update(Source.t(), String.t(), String.t(), String.t()) ::
          {:ok, Source.t()} | {:error, any()}
  def update(source, url, type, name) do
    Source.changeset(source, %{
      name: name,
      url: url,
      type: type,
      icon: get_icon(url)
    })
    |> Repo.update()
  end

  defp maybe_get_existing_source(url) do
    case get_by_url(url) do
      {:ok, source} ->
        source

      {:error, _error} ->
        %Source{}
    end
  end

  defp get_icon(url) do
    %URI{scheme: scheme, host: host} = URI.parse(url)
    "#{scheme}://#{host}/favicon.ico"
  end

  @doc """
  Lists all sources in the database.
  """
  @spec list() :: [Source.t()]
  def list do
    Repo.all(Source)
  end

  @doc """
  Lists all sources in an account.
  """
  @spec list(Account.t()) :: [Source.t()]
  def list(account) do
    account
    |> Ecto.assoc(:sources)
    |> preload(:entries)
    |> Repo.all()
  end

  @doc """
  Gets a source by ID.
  """
  @spec get(Ecto.UUID.t()) :: {:ok, Source.t()} | {:error, :source_not_found}
  def get(id) do
    Repo.get(Source, id)
    |> case do
      nil -> {:error, :source_not_found}
      source -> {:ok, Repo.preload(source, :entries)}
    end
  end

  @doc """
  Gets a source by URL.
  """
  @spec get_by_url(String.t()) :: {:ok, Source.t()} | {:error, :source_not_found}
  def get_by_url(url) do
    Source
    |> where(url: ^url)
    |> Repo.one()
    |> case do
      nil -> {:error, :source_not_found}
      source -> {:ok, source}
    end
  end

  @doc """
  Adds a source to an account.
  """
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

  @doc """
  Removes a source from an account.
  """
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
