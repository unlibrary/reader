defmodule UnLib.Feeds.Data do
  @moduledoc """
  Struct representing a feed.

  Used internally to manage feeds.
  """

  alias UnLib.{Source, Feeds.Data, Entry, ParsedEntry}

  defstruct xml: nil, entries: [], source: nil, error: nil

  @type t :: %__MODULE__{
          :xml => nil | String.t(),
          :entries => list() | [ParsedEntry.t() | Entry.t()],
          :source => Source.t(),
          :error => nil | String.t()
        }

  @spec from(Source.t()) :: t()
  def from(source) do
    %Data{source: source}
  end
end
