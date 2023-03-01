defmodule UnLib.ParsedEntry do
  @moduledoc """
  Map representing a parsed RSS entry.
  """

  alias UnLib.{Repo, Source, Entry, ReadEntry, ParsedEntry}
  alias UnLib.{Entries, DateTime}

  import Ecto.Query

  defstruct [:date, :title, :body, :url]

  @type t() :: %ParsedEntry{
          date: DateTime.rfc822(),
          title: String.t(),
          body: String.t(),
          url: String.t()
        }

  @type rss_entry() :: %{String.t() => String.t()}

  @spec from(rss_entry()) :: t()
  def from(%{
        "pub_date" => pub_date,
        "title" => title,
        "content" => content,
        "description" => description,
        "link" => link
      }) do
    body =
      if content do
        content
      else
        description
      end

    %ParsedEntry{
      date: pub_date,
      title: title,
      body: body,
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
    maybe_get(entry) !== nil
  end

  @spec already_read?(t()) :: boolean()
  def already_read?(entry) do
    in_read_entries?(entry)
  end

  @spec in_read_entries?(t()) :: boolean()
  defp in_read_entries?(parsed_entry) do
    maybe_get_read_entry(parsed_entry) !== nil
  end

  @spec maybe_get(t()) :: Entry.t() | nil
  defp maybe_get(%ParsedEntry{url: entry_url}) do
    Entry
    |> where(url: ^entry_url)
    |> Repo.one()
  end

  @spec maybe_get_read_entry(t()) :: ReadEntry.t() | nil
  def maybe_get_read_entry(%ParsedEntry{url: entry_url}) do
    ReadEntry
    |> where(url: ^entry_url)
    |> Repo.one()
  end
end
