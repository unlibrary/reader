defmodule UnLib.ParsedEntry do
  @moduledoc """
  Struct representing a parsed RSS entry.
  """

  alias UnLib.{Repo, Source, Entry, ReadEntry, ParsedEntry}
  alias UnLib.{Entries, DateTime}

  import Ecto.Query

  defstruct [:datetime, :title, :body, :url]

  @type t() :: %ParsedEntry{
          datetime: DateTime.rfc2822() | DateTime.rfc3339(),
          title: String.t(),
          body: String.t(),
          url: String.t()
        }

  @type rss_entry() :: %{
          updated: String.t(),
          published: String.t(),
          title: String.t(),
          content: String.t(),
          description: String.t(),
          url: String.t()
        }

  @spec from(rss_entry()) :: t()
  def from(rss_entry) do
    %ParsedEntry{
      datetime: rss_entry[:published] || rss_entry[:updated],
      title: rss_entry[:title],
      body: rss_entry[:content] || rss_entry[:description],
      url: rss_entry[:url]
    }
  end

  @spec save(Source.t(), t()) :: Entry.t()
  def save(source, entry) do
    datetime =
      case DateTime.detect_format(entry.datetime) do
        :rfc2822 -> DateTime.from_rfc2822(entry.datetime)
        :rfc3339 -> DateTime.from_rfc3339(entry.datetime)
      end

    Entries.new(source, datetime, entry.title, entry.body, entry.url)
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
