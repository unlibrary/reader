defmodule UnLib.Entries do
  @moduledoc """
  Manages RSS entries.
  """

  alias UnLib.{Repo, Account, Source, Entry}

  import Ecto.Query

  @spec new(Source.t(), NaiveDateTime.t(), String.t(), String.t(), String.t()) :: Entry.t()
  def new(source, date, title, body, url) do
    Ecto.build_assoc(source, :entries, %{
      date: date,
      title: title,
      body: body,
      url: url
    })
    |> Repo.insert!()
  end

  @spec list(Source.t()) :: [Entry.t()]
  @spec list(Account.t()) :: [Entry.t()]
  def list(source_or_account) do
    source_or_account
    |> list_all()
    |> Enum.reject(& &1.read?)
  end

  @spec list_all(Source.t()) :: [Entry.t()]
  def list_all(%Source{} = source) do
    Entry
    |> where(source_id: ^source.id)
    |> order_by([e], desc: e.date)
    |> Repo.all()
    |> Repo.preload(:source)
  end

  @spec list_all(Account.t()) :: [Entry.t()]
  def list_all(%Account{} = account) do
    account.sources
    |> Ecto.assoc(:entries)
    |> order_by([e], desc: e.date)
    |> preload(:source)
    |> Repo.all()
  end

  @spec get(Ecto.UUID.t()) :: {:ok, Entry.t()} | {:error, any()}
  def get(id) do
    Repo.get(Entry, id)
    |> case do
      nil -> {:error, "entry not found"}
      entry -> {:ok, Repo.preload(entry, :source)}
    end
  end

  @spec get_by_url(String.t()) :: {:ok, Entry.t()} | {:error, any()}
  def get_by_url(url) do
    Entry
    |> where(url: ^url)
    |> Repo.one()
    |> case do
      nil -> {:error, "entry not found"}
      entry -> {:ok, Repo.preload(entry, :source)}
    end
  end

  @spec read(Entry.t()) :: {:ok, Entry.t()} | {:error, any()}
  def read(entry) do
    Repo.transaction(fn ->
      with {:ok, entry} <- mark_entry_as_read(entry),
           {:ok, _source} <- add_url_to_read_list(entry.url, entry.source) do
        entry
      else
        {:error, error} -> Repo.rollback(error)
      end
    end)
  end

  defp mark_entry_as_read(entry) do
    Entry.changeset(entry, %{read?: true})
    |> Repo.update()
  end

  defp add_url_to_read_list(url, source) do
    Source.changeset(source, %{
      read_list: [url | source.read_list]
    })
    |> Repo.update()
  end

  @spec read_all(Account.t()) :: :ok
  @spec read_all(Source.t()) :: :ok
  def read_all(source_or_account) do
    source_or_account
    |> list_all()
    |> Enum.each(&read/1)
  end

  @spec unread(Entry.t()) :: {:ok, Entry.t()} | {:error, any()}
  def unread(entry) do
    Repo.transaction(fn ->
      with {:ok, entry} <- mark_entry_as_unread(entry),
           {:ok, _source} <- remove_url_from_read_list(entry.url, entry.source) do
        entry
      else
        {:error, error} -> Repo.rollback(error)
      end
    end)
  end

  defp mark_entry_as_unread(entry) do
    Entry.changeset(entry, %{read?: false})
    |> Repo.update()
  end

  defp remove_url_from_read_list(url, source) do
    Source.changeset(source, %{
      read_list: source.read_list -- [url]
    })
    |> Repo.update()
  end

  @spec unread_all(Account.t()) :: :ok
  @spec unread_all(Source.t()) :: :ok
  def unread_all(source_or_account) do
    source_or_account
    |> list_all()
    |> Enum.each(&unread/1)
  end

  @spec delete(Ecto.UUID.t()) :: :ok
  def delete(id) when is_binary(id) do
    Entry
    |> where(id: ^id)
    |> Repo.delete_all()

    :ok
  end

  @spec delete(Entry.t()) :: :ok
  def delete(%Entry{id: id}) do
    delete(id)
  end

  @spec prune(Source.t()) :: :ok
  def prune(%Source{id: id}) do
    Entry
    |> where(read?: true)
    |> where(source_id: ^id)
    |> Repo.delete_all()

    :ok
  end

  @spec prune(Account.t()) :: :ok
  def prune(%Account{sources: sources}) do
    Enum.each(sources, &prune/1)
    :ok
  end

  @spec prune_all(Source.t()) :: :ok
  def prune_all(%Source{id: id}) do
    Entry
    |> where(source_id: ^id)
    |> Repo.delete_all()

    :ok
  end

  @spec prune_all(Account.t()) :: :ok
  def prune_all(%Account{sources: sources}) do
    Enum.each(sources, &prune_all/1)
    :ok
  end
end
