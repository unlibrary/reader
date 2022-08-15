defmodule UnLib.DateTime do
  @moduledoc """
  Helpers for converting between datetime formats.
  """

  alias UnLib.{DateTime.RFC2822}

  @type rfc822 :: RFC2822.t()

  @spec now :: NaiveDateTime.t()
  def now do
    DateTime.utc_now()
    |> DateTime.to_naive()
    |> NaiveDateTime.truncate(:second)
  end

  @spec human_datetime(NaiveDateTime.t()) :: String.t()
  def human_datetime(datetime) do
    "#{datetime.day}/#{datetime.month}/#{datetime.year}"
  end

  @spec to_rfc822(NaiveDateTime.t()) :: rfc822()
  def to_rfc822(datetime) do
    Calendar.strftime(datetime, "%a, %d %b %Y %T %z")
  end

  @spec from_rfc822(rfc822()) :: NaiveDateTime.t()
  def from_rfc822(datetime) do
    {:ok, datetime} = RFC2822.parse(datetime)
    datetime
  end
end
