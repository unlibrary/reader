defmodule UnLib.ParsedEntry do
  @moduledoc """
  Map representing a parsed RSS entry.
  """

  alias UnLib.{Repo, Source, Entry, ParsedEntry}
  alias UnLib.{Entries, DateTime}

  import Ecto.Query

  defstruct [:date, :title, :body, :url]

  @type t :: %ParsedEntry{
          date: DateTime.rfc822(),
          title: String.t(),
          body: String.t(),
          url: String.t()
        }

  @type rss_entry :: %{String.t() => String.t()}

  @spec from(rss_entry()) :: t()
  def from(%{
        "pub_date" => pub_date,
        "title" => title,
        "content" => content,
        "link" => link
      }) do
    %ParsedEntry{
      date: pub_date,
      title: title,
      body: content,
      url: link
    }
  end

  @spec save(Source.t(), t()) :: Entry.t()
  def save(source, entry) do
    date = DateTime.from_rfc822(entry.date)
    Entries.new(source, date, entry.title, entry.body, entry.url)
  end

  @spec already_saved?(t()) :: boolean()
  def already_saved?(entry) do
    case maybe_get(entry) do
      %Entry{} -> true
      _ -> false
    end
  end

  defp maybe_get(entry) do
    date = DateTime.from_rfc822(entry.date)

    Entry
    |> where(date: ^date)
    |> where(title: ^entry.title)
    |> where(body: ^entry.body)
    |> Repo.one()
  end
end
