defmodule UnLib.DateTime.RFC3339 do
  @moduledoc """
  Parses RFC3339 datetimes into `NaiveDateTime`.

  Copyright Lau Taarnskov. I stole this from the Calendar library, I'm not smart enough to write this mess ;)

  Source: https://github.com/lau/calendar/blob/master/lib/calendar/date_time/parse.ex#L259
  License: https://github.com/lau/calendar/blob/master/LICENSE
  """

  @type t() :: String.t()

  @spec parse(t()) :: {:ok, NaiveDateTime.t()} | {:error, any()}

  # faster version for certain formats of of RFC3339
  def parse(
        <<year::4-bytes, ?-, month::2-bytes, ?-, day::2-bytes, ?T, hour::2-bytes, ?:,
          min::2-bytes, ?:, sec::2-bytes, ?Z>>
      ) do
    {{year |> to_int, month |> to_int, day |> to_int},
     {hour |> to_int, min |> to_int, sec |> to_int}}
    |> NaiveDateTime.from_erl()
  end

  def parse(string) do
    if parsed = Regex.named_captures(rfc3339_regex(), string) do
      parse_rfc3339_as_utc_parsed_string(
        parsed,
        parsed["z"],
        parsed["offset_hours"],
        parsed["offset_mins"]
      )
    else
      {:error, :bad_format}
    end
  end

  defp rfc3339_regex do
    ~r/(?<year>[\d]{4})[^\d]?(?<month>[\d]{2})[^\d]?(?<day>[\d]{2})[^\d](?<hour>[\d]{2})[^\d]?(?<min>[\d]{2})[^\d]?(?<sec>[\d]{2})([\.\,](?<fraction>[\d]+))?((?<z>[zZ])|((?<offset_sign>[\+\-])(?<offset_hours>[\d]{1,2}):?(?<offset_mins>[\d]{2})))/
  end

  defp parse_rfc3339_as_utc_parsed_string(mapped, z, _offset_hours, _offset_mins)
       when z == "Z" or z == "z" do
    parse_rfc3339_as_utc_parsed_string(mapped, "", "00", "00")
  end

  defp parse_rfc3339_as_utc_parsed_string(mapped, _z, offset_hours, offset_mins)
       when offset_hours == "00" and offset_mins == "00" do
    NaiveDateTime.from_erl(erl_date_time_from_regex_map(mapped))
  end

  defp parse_rfc3339_as_utc_parsed_string(mapped, _z, offset_hours, offset_mins) do
    offset_in_secs = hours_mins_to_secs!(offset_hours, offset_mins)

    offset_in_secs =
      case mapped["offset_sign"] do
        "-" -> offset_in_secs * -1
        _ -> offset_in_secs
      end

    erl_date_time = erl_date_time_from_regex_map(mapped)

    parse_rfc3339_as_utc_with_offset(
      offset_in_secs,
      erl_date_time
    )
  end

  defp parse_rfc3339_as_utc_with_offset(offset_in_secs, erl_date_time) do
    greg_secs = :calendar.datetime_to_gregorian_seconds(erl_date_time)
    new_time = :calendar.gregorian_seconds_to_datetime(greg_secs - offset_in_secs)

    NaiveDateTime.from_erl(new_time)
  end

  defp erl_date_time_from_regex_map(mapped) do
    {{mapped["year"] |> to_int, mapped["month"] |> to_int, mapped["day"] |> to_int},
     {mapped["hour"] |> to_int, mapped["min"] |> to_int, mapped["sec"] |> to_int}}
  end

  def hours_mins_to_secs!(hours, mins) do
    hours_int = hours |> to_int
    mins_int = mins |> to_int
    hours_int * 3600 + mins_int * 60
  end

  defp to_int(string) do
    {int, _} = Integer.parse(string)
    int
  end
end
