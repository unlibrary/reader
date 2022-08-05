defmodule UnLib.Feeds do
  @moduledoc """
  Manages pulling, parsing and diffing feeds.
  """

  alias UnLib.{Feeds.State, ParsedEntry}

  def check(source) do
    State.from(source)
    |> fetch()
    |> parse()
  end

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
