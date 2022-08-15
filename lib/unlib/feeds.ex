defmodule UnLib.Feeds do
  @moduledoc """
  Manages pulling, parsing and diffing feeds.
  """

  alias UnLib.{Source, Feeds.Data, ParsedEntry}

  @doc """
  Method to pull new entries for all sources.

  Runs pull/1 for every source in the database.
  """
  @spec pull_all :: [Data.t()]
  def pull_all do
    Source
    |> UnLib.Repo.all()
    |> Enum.map(&Task.async(fn -> pull(&1) end))
    |> Task.await_many(:infinity)
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
  end

  @doc """
  Method to fetch and save new entries to the database.

  The main difference between this method and `check/1` is that this method saves the new entries. It also returns a `UnLib.Feeds.Data` struct, but it contains `UnLib.Entry` instead of `UnLib.ParsedEntry`, since the items are already saved to the database.
  """
  @spec pull(Source.t()) :: Data.t()
  def pull(source) do
    source
    |> check()
    |> save()
  end

  @spec fetch(Data.t()) :: Data.t()
  def fetch(data) do
    data.source.url
    |> make_request()
    |> handle_response(data)
  end

  defp make_request(url) do
    :get
    |> Finch.build(url)
    |> Finch.request(UnLib.Finch)
  end

  defp handle_response(response, data) do
    case response do
      {:ok, %Finch.Response{status: 200, body: response_data}} ->
        %Data{data | xml: response_data}

      {:error, _} ->
        %Data{data | error: "could not download feed for #{data.source.name}"}
    end
  end

  @spec parse(Data.t()) :: Data.t()
  def parse(data) when is_nil(data.error) do
    {:ok, parsed_xml} = FastRSS.parse(data.xml)

    entries =
      parsed_xml["items"]
      |> Enum.take(5)
      |> Enum.map(&ParsedEntry.from/1)
      |> Enum.reject(&ParsedEntry.already_saved?/1)
      |> Enum.reject(&ParsedEntry.already_read?(&1, data.source))

    %Data{data | entries: entries}
  end

  def parse(data) do
    %Data{data | entries: []}
  end

  @spec save(Data.t()) :: Data.t()
  def save(data) do
    entries = Enum.map(data.entries, &ParsedEntry.save(data.source, &1))
    %Data{data | entries: entries}
  end
end
