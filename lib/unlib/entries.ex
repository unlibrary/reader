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

  @spec list :: [Entry.t()]
  def list do
    Repo.all(Entry)
  end

  @spec list(Source.t()) :: [Entry.t()]
  def list(%Source{} = source) do
    Entry
    |> where(source_url: ^source.url)
    |> Repo.all()
    |> Repo.preload(:source)
  end

  @spec list(Account.t()) :: [Entry.t()]
  def list(%Account{} = account) do
    account = Repo.preload(account, sources: :entries)

    account.sources
    |> Enum.map(fn source -> source.entries end)
    |> List.flatten()
  end

  @spec get(String.t()) :: {:ok, Entry.t()} | {:error, any()}
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

  @spec prune(:all | :read) :: :ok
  def prune(mode \\ :read)

  def prune(:all) do
    Repo.delete_all(Entry)
    :ok
  end

  def prune(:read) do
    Entry
    |> where(read?: true)
    |> Repo.delete_all()

    :ok
  end

  @spec prune(Source.t(), :all | :read) :: :ok
  def prune(source, mode)

  def prune(source, :all) do
    Entry
    |> where(source_url: ^source.url)
    |> Repo.delete_all()

    :ok
  end

  def prune(source, :read) do
    Entry
    |> where(read?: true)
    |> where(source_url: ^source.url)
    |> Repo.delete_all()

    :ok
  end
end
