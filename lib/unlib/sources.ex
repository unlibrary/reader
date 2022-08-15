defmodule UnLib.Sources do
  @moduledoc """
  Manages sources for an user.
  """

  alias UnLib.{Repo, Source, Account, Feeds, Feeds.Data}
  import Ecto.{Changeset, Query}

  @type list_opts :: [
          account: Account.t()
        ]

  @spec new(String.t(), atom(), String.t() | nil) :: {:ok, Source.t()} | {:error, any()}
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

  @spec list(list_opts()) :: [Source.t()]

  def list(opts \\ [])

  def list(account: account) do
    account.sources
  end

  def list(_opts) do
    Repo.all(Source)
  end

  @spec get_by_url(String.t()) :: {:ok, Source.t()} | {:error, any()}
  def get_by_url(url) do
    Source
    |> where(url: ^url)
    |> Repo.one()
    |> case do
      nil -> {:error, "source not found"}
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
    else
      {:error, "already in account"}
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

  # i cant fking explain what this function does (and i hate comments),
  # but here i go:
  #
  # i delete all read posts from the database when the user runs prune,
  # but i dont want to redownload them. to prevent this i keep a list of urls
  # in the source that holds all urls of posts i already read.
  # but this list can get very long. the pull function only downloads the first
  # x posts (configurable), so really i only need to check
  # if they are read (the rest will never be redownloaded). this function
  # removes all unneeded urls from the read_list on a source struct

  @spec clean_read_list(Source.t()) :: {:ok, Source.t()} | {:error, any()}
  def clean_read_list(source) do
    entry_urls = get_newest_entries_urls(source)
    read_list = only_keep_newest_entry_urls(entry_urls, source.read_list)

    Source.changeset(source, %{read_list: read_list})
    |> Repo.update()
  end

  defp get_newest_entries_urls(source) do
    %Data{entries: entries} = Feeds.check(source)
    Enum.map(entries, fn entry -> entry.url end)
  end

  defp only_keep_newest_entry_urls(entry_urls, read_list) do
    Enum.filter(read_list, fn url -> url in entry_urls end)
  end
end
