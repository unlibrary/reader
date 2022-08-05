defmodule UnLib.Feeds do
  @moduledoc """
  Manages pulling, parsing and diffing feeds.
  """

  alias UnLib.{Source, Feeds.State, ParsedEntry}

  @doc """
  Method to fetch data from a source.

  Returns a `UnLib.Feeds.State` struct containing a list of `UnLib.ParsedEntry`. These entries can then be displayed to the user and optionally downloaded using `UnLib.ParsedEntry.download/2`.
  """
  @spec check(Source.t()) :: State.t()
  def check(source) do
    State.from(source)
    |> fetch()
    |> parse()
  end

  @doc """
  Method to fetch and save new entries to the database.

  The main difference between this method and `check/1` is that this method downloads the new entries. It also returns a `UnLib.Feeds.State` struct, but it contains `UnLib.Entry` instead of `UnLib.ParsedEntry`, since the items are already saved to the database.
  """
  @spec pull(Source.t()) :: State.t()
  def pull(source) do
    source
    |> check()
    |> save()
  end

  @spec fetch(State.t()) :: State.t()
  def fetch(state) do
    response_data =
      state.source.url
      |> make_request()
      |> handle_response()

    %State{state | xml: response_data}
  end

  defp make_request(url) do
    :get
    |> Finch.build(url)
    |> Finch.request(UnLib.Finch)
  end

  defp handle_response(response) do
    {:ok, %Finch.Response{status: 200, body: response_data}} = response
    response_data
  end

  @spec parse(State.t()) :: State.t()
  def parse(state) do
    {:ok, parsed_xml} = FastRSS.parse(state.xml)

    entries =
      parsed_xml["items"]
      |> Enum.take(5)
      |> Enum.reject(&ParsedEntry.already_saved?/1)

    %State{state | entries: entries}
  end

  @spec save(State.t()) :: State.t()
  def save(state) do
    entries = Enum.each(state.entries, &ParsedEntry.download(state.source, &1))
    %State{state | entries: entries}
  end
end
