defmodule UnLib.Entries do
  @moduledoc """
  Manages RSS entries.
  """

  alias UnLib.{Repo, Entry}
  alias UnLib.{DateTime}

  @spec new(DateTime.rfc822(), String.t(), String.t()) :: Entry.t()
  def new(date, title, body) do
    date = DateTime.from_rfc822(date)

    Entry.changeset(%Entry{}, %{
      date: date,
      title: title,
      body: body
    })
    |> Repo.insert!()
  end
end
