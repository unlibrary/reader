defmodule UnLib.Entries do
  @moduledoc """
  Manages RSS entries.
  """

  alias UnLib.{Repo, Source, Entry}
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
  def list(source) do
    Entry
    |> where(source: ^source)
    |> Repo.all()
  end

  @spec prune :: :ok
  def prune do
    Repo.delete_all(Entry)
    :ok
  end
end
