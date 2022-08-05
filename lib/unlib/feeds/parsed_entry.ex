defmodule UnLib.ParsedEntry do
  @moduledoc """
  Map representing a parsed RSS entry.
  """

  alias UnLib.{Repo, Source, Entry}
  alias UnLib.{Entries, DateTime}

  import Ecto.Query

  @type t :: %{String.t() => String.t()}

  @spec download(Source.t(), t()) :: Entry.t()
  def download(source, entry) do
    Entries.new(source, entry["pub_date"], entry["title"], entry["content"])
  end

  @spec already_saved?(t()) :: boolean()
  def already_saved?(entry) do
    case attempt_entry_from_db(entry) do
      %Entry{} -> true
      _ -> false
    end
  end

  defp attempt_entry_from_db(entry) do
    date = DateTime.from_rfc822(entry["pub_date"])

    Entry
    |> where(date: ^date)
    |> where(title: ^entry["title"])
    |> where(content: ^entry["content"])
    |> Repo.one()
  end
end
