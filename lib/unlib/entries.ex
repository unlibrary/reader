defmodule UnLib.Entries do
  @moduledoc """
  Manages RSS entries.
  """

  alias UnLib.{Repo, Account, Source, Entry}
  alias UnLib.{DateTime}

  import Ecto.Query

  @spec new(Source.t(), DateTime.rfc822(), String.t(), String.t()) :: Entry.t()
  def new(source, date, title, body) do
    date = DateTime.from_rfc822(date)

    Ecto.build_assoc(source, :entries, %{
      date: date,
      title: title,
      body: body
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
    |> where(source_id: ^source.id)
    |> Repo.all()
  end

  @spec list(Account.t()) :: [Entry.t()]
  def list(%Account{} = account) do
    account = Repo.preload(account, sources: :entries)

    account.sources
    |> Enum.map(fn source -> source.entries end)
    |> List.flatten()
  end

  @spec prune :: :ok
  def prune do
    Repo.delete_all(Entry)
    :ok
  end

  @spec prune(Source.t()) :: :ok
  def prune(source) do
    Entry
    |> where(source_id: ^source.id)
    |> Repo.delete_all()

    :ok
  end
end
