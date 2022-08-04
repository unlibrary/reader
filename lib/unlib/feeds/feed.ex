defmodule UnLib.Feed do
  @moduledoc """
  Struct representing a feed.

  Used internally to manage feeds.
  """

  alias UnLib.{Source, Feed}

  defstruct xml: nil, xml_digest: nil, post_digests: [], source: nil, posts: []

  @type t :: %{
          xml: String.t(),
          xml_digest: String.t(),
          post_digests: [
            String.t()
          ],
          source: Source.t()
        }

  @spec from(Source.t()) :: t()
  def from(source) do
    %Feed{source: source}
  end
end
