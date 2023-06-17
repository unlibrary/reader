defmodule UnLib.ParsedEntry do
  @moduledoc """
  Struct representing a parsed RSS entry.

  The `ParsedEntry` struct is an intermediate representation. It is used to
  easily digest the output of `ElixirFeedParser`, before it is saved to
  the database.
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

  @doc """
  Creates an `ParsedEntry` struct from the output of `ElixirFeedParser`.
  """
  @spec from(rss_entry()) :: t()
  def from(rss_entry) do
    %ParsedEntry{
      datetime: get_datetime(rss_entry),
      title: get_title(rss_entry),
      body: get_content(rss_entry),
      url: rss_entry[:url]
    }
  end

  defp get_datetime(rss_entry) do
    rss_entry[:published] || rss_entry[:updated]
  end

  defp get_title(rss_entry) do
    rss_entry[:title] || get_content(rss_entry) |> truncate()
  end

  defp get_content(rss_entry) do
    rss_entry[:content] || rss_entry[:description] || rss_entry[:url]
  end

  defp truncate(string, opts \\ []) do
    length = Keyword.get(opts, :length, 12)

    cond do
      not String.valid?(string) -> string
      String.length(string) < length -> string
      true -> String.slice(string, 0..length) <> "..."
    end
  end

  @doc """
  Persists a `ParsedEntry` to the database as an `Entry`.
  """
  @spec save(Source.t(), t()) :: Entry.t()
  def save(source, entry) do
    datetime =
      case DateTime.detect_format(entry.datetime) do
        :rfc2822 -> DateTime.from_rfc2822(entry.datetime)
        :rfc3339 -> DateTime.from_rfc3339(entry.datetime)
        :unknown -> DateTime.now()
      end

    Entries.new(source, datetime, entry.title, entry.body, entry.url)
  end

  @doc """
  Checks if a `ParsedEntry` already has an `Entry` counterpart in the database.
  """
  @spec already_saved?(t()) :: boolean()
  def already_saved?(entry) do
    maybe_get_entry_by_url(entry) !== nil
  end

  @doc """
  Checks if a `ParsedEntry` already as a `ReadEntry` counterpart in the database.
  """
  @spec already_read?(t()) :: boolean()
  def already_read?(entry) do
    in_read_entries?(entry)
  end

  @spec in_read_entries?(t()) :: boolean()
  defp in_read_entries?(parsed_entry) do
    maybe_get_read_entry(parsed_entry) !== nil
  end

  @spec maybe_get_entry_by_url(t()) :: Entry.t() | nil
  defp maybe_get_entry_by_url(%ParsedEntry{url: entry_url}) do
    Entry
    |> where(url: ^entry_url)
    |> Repo.one()
  end

  @spec maybe_get_read_entry(t()) :: ReadEntry.t() | nil
  defp maybe_get_read_entry(%ParsedEntry{url: entry_url}) do
    ReadEntry
    |> where(url: ^entry_url)
    |> Repo.one()
  end
end
