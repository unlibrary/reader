defmodule UnLib.DateTime do
  @moduledoc """
  Helpers for converting between datetime formats.
  """

  alias UnLib.DateTime.{RFC2822, RFC3339}

  @type rfc2822() :: RFC2822.t()
  @type rfc3339() :: RFC3339.t()

  @spec now() :: NaiveDateTime.t()
  def now do
    DateTime.utc_now()
    |> DateTime.to_naive()
    |> NaiveDateTime.truncate(:second)
  end

  @spec human_datetime(NaiveDateTime.t()) :: String.t()
  def human_datetime(datetime) do
    "#{datetime.day}/#{datetime.month}/#{datetime.year}"
  end

  @spec detect_format(rfc2822() | rfc3339()) :: :rfc2822 | :rfc3339
  def detect_format(datetime_string) do
    if String.contains?(datetime_string, " ") do
      :rfc2822
    else
      :rfc3339
    end
  end

  @spec to_rfc2822(NaiveDateTime.t()) :: rfc2822()
  def to_rfc2822(datetime) do
    Calendar.strftime(datetime, "%a, %d %b %Y %H:%M:%S %z")
  end

  @spec from_rfc2822(rfc2822()) :: NaiveDateTime.t()
  def from_rfc2822(datetime_string) do
    {:ok, datetime} = RFC2822.parse(datetime_string)
    datetime
  end

  @spec to_rfc3339(NaiveDateTime.t()) :: rfc3339()
  def to_rfc3339(datetime) do
    Calendar.strftime(datetime, "+%Y-%m-%dT%H:%M:%SZ")
  end

  @spec from_rfc3339(rfc3339()) :: NaiveDateTime.t()
  def from_rfc3339(datetime_string) do
    {:ok, datetime} = RFC3339.parse(datetime_string)
    datetime
  end
end
