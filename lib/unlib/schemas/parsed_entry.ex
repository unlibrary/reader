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
    case maybe_get(entry) do
      %Entry{} -> true
      _ -> false
    end
  end

  defp maybe_get(entry) do
    Entry
    |> where(url: ^entry.url)
    |> Repo.one()
  end

  @spec already_read?(t(), Source.t()) :: boolean()
  def already_read?(entry, source) do
    downloaded_and_read(entry) or in_source_read_list(entry.url, source)
  end

  defp downloaded_and_read(parsed_entry) do
    if entry = maybe_get(parsed_entry) do
      entry.read?
    else
      false
    end
  end

  defp in_source_read_list(url, source) do
    url in source.read_list
  end
end
