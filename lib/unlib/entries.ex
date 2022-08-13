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

  @spec prune :: :ok
  def prune do
    Repo.delete_all(Entry)
    :ok
  end

  @spec prune(Source.t()) :: :ok
  def prune(source) do
    Entry
    |> where(source_url: ^source.url)
    |> Repo.delete_all()

    :ok
  end
end
