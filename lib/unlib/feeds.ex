defmodule UnLib.Feeds do
  @moduledoc """
  Manages pulling, parsing and diffing feeds.
  """

  alias UnLib.{Feed}
  alias UnLib.{Entries}

  # def pull(source) do
  #   Feed.from(source)
  #   |> fetch()
  #   |> parse()
  # end

  @spec fetch(Feed.t()) :: Feed.t()
  def fetch(feed) do
    response_data =
      feed.source.url
      |> make_request()
      |> handle_response()

    %Feed{feed | xml: response_data}
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

  @spec parse(Feed.t()) :: Feed.t()
  def parse(feed) do
    {:ok, parsed_xml} = FastRSS.parse(feed.xml)

    parsed_xml["items"]
    |> Enum.take(5)
    |> Enum.map(&Entries.new(&1["pub_date"], &1["title"], &1["content"]))
  end
end
