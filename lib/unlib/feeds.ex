defmodule UnLib.Feeds do
  @moduledoc """
  Manages pulling, parsing and diffing feeds.
  """

  @amount_of_entries_to_save 20

  alias UnLib.{Account, Source, Sources, Feeds.Data, ParsedEntry}

  @type finch_response() :: {:ok, Finch.Response.t()} | {:error, any()}

  @doc """
  Method to pull new entries for all sources.

  Runs pull/1 for every source in the database.
  """
  @spec pull :: [Data.t()]
  def pull do
    Sources.list()
    |> pull_sources()
  end

  defp pull_sources(sources) do
    sources
    |> Enum.map(&Task.async(fn -> pull(&1) end))
    |> Task.await_many(:infinity)
  end

  @doc """
  Method to fetch and save new entries to the database.

  The main difference between this method and `check/1` is that this method saves the new entries. It also returns a `UnLib.Feeds.Data` struct, but it contains `UnLib.Entry` instead of `UnLib.ParsedEntry`, since the items are already saved to the database.
  """
  @spec pull(Source.t()) :: Data.t()
  def pull(%Source{} = source) do
    source
    |> check()
    |> save()
  end

  @spec pull(Account.t()) :: [Data.t()]
  def pull(%Account{} = account) do
    account
    |> Sources.list()
    |> pull_sources()
  end

  @doc """
  Method to fetch data from a source.

  Returns a `UnLib.Feeds.Data` struct containing a list of `UnLib.ParsedEntry`. These entries can then be displayed to the user and optionally downloaded using `UnLib.ParsedEntry.save/2`.

  Entries that are already saved or read are not returned.
  """
  @spec check(Source.t()) :: Data.t()
  def check(source) do
    Data.from(source)
    |> fetch()
    |> parse()
    |> filter()
  end

  @spec fetch(Data.t()) :: Data.t()
  def fetch(data) do
    data.source.url
    |> make_request()
    |> handle_response(data)
  end

  @spec make_request(String.t()) :: finch_response()
  defp make_request(url) do
    :get
    |> Finch.build(url)
    |> Finch.request(UnLib.Finch)
  end

  @spec handle_response(finch_response(), Data.t()) :: Data.t()
  defp handle_response(response, data) do
    case response do
      {:ok, %Finch.Response{status: 200, body: response_data}} ->
        %Data{data | xml: response_data}

      {:ok, %Finch.Response{status: status}} ->
        %Data{data | error: "could not download feed for #{data.source.name}, got #{status}"}

      {:error, _} ->
        %Data{data | error: "could not download feed for #{data.source.name}"}
    end
  end

  @spec parse(Data.t()) :: Data.t()
  def parse(data) when is_nil(data.error) do
    parsed_xml = ElixirFeedParser.parse(data.xml)
    entries = Enum.map(parsed_xml.entries, &ParsedEntry.from/1)

    %Data{data | entries: entries}
  end

  def parse(data) do
    %Data{data | entries: []}
  end

  @spec filter(Data.t()) :: Data.t()
  def filter(data) when is_nil(data.error) do
    entries =
      data.entries
      |> Enum.take(@amount_of_entries_to_save)
      |> remove_duplicates()
      |> Enum.reject(&already_read_or_saved?/1)

    %Data{data | entries: entries}
  end

  def filter(data) do
    %Data{data | entries: []}
  end

  # This function filters out multiple entries with the same
  # URL. I don't think the RSS spec allows it, but it happened in
  # one of the feeds I was following.
  #
  # Currently, we keep the first entry, and all later entries with
  # the same URL are discarded.

  defp remove_duplicates(parsed_entries) do
    parsed_entries
    |> Enum.reduce(%{}, fn parsed_entry, acc ->
      Map.put(acc, parsed_entry.url, parsed_entry)
    end)
    |> Map.values()
  end

  @spec already_read_or_saved?(ParsedEntry.t()) :: boolean()
  defp already_read_or_saved?(p) do
    ParsedEntry.already_saved?(p) ||
      ParsedEntry.already_read?(p)
  end

  @spec save(Data.t()) :: Data.t()
  def save(data) do
    entries = Enum.map(data.entries, &ParsedEntry.save(data.source, &1))
    %Data{data | entries: entries}
  end
end
