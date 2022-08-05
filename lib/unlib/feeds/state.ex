defmodule UnLib.Feeds.State do
  @moduledoc """
  Struct representing a feed.

  Used internally to manage feeds.
  """

  alias UnLib.{Source, Feeds.State, Entry, ParsedEntry}

  defstruct xml: nil, entries: [], source: nil

  @type t :: %{
          xml: String.t(),
          entries: [ParsedEntry.t() | Entry.t()],
          source: Source.t()
        }
  @spec from(Source.t()) :: t()
  def from(source) do
    %State{source: source}
  end
end
