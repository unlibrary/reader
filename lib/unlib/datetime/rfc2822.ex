defmodule UnLib.DateTime.RFC2822 do
  @moduledoc """
  Parses RFC822 datetimes into `NaiveDateTime`.

  Copyright Lau Taarnskov. I stole this from the Calendar library, I'm not smart enough to write this mess ;)

  Source: https://github.com/lau/calendar/blob/master/lib/calendar/date_time/parse.ex#L82
  License: https://github.com/lau/calendar/blob/master/LICENSE
  """

  @type t :: String.t()

  @spec parse(t()) :: {:ok, NaiveDateTime.t()} | {:error, any()}
  def parse(string) do
    cap = Regex.named_captures(rfc2822_regex(), string)
    month_number = number_for_month(cap["month"])

    NaiveDateTime.from_erl(
      {{cap["year"] |> to_int, month_number, cap["day"] |> to_int},
       {cap["hour"] |> to_int, cap["min"] |> to_int, cap["sec"] |> to_int}}
    )
  end

  defp rfc2822_regex do
    ~r/(?<day>[\d]{1,2})[\s]+(?<month>[^\d]{3})[\s]+(?<year>[\d]{4})[\s]+(?<hour>[\d]{2})[^\d]?(?<min>[\d]{2})[^\d]?(?<sec>[\d]{2})[^\d]?(((?<offset_sign>[+-])(?<offset_hours>[\d]{2})(?<offset_mins>[\d]{2})|(?<offset_letters>[A-Z]{1,3})))?/
  end

  defp number_for_month(string) do
    string
    |> String.downcase()
    |> month_number()
  end

  def month_number(month_name) do
    months = %{
      "jan" => 1,
      "feb" => 2,
      "mar" => 3,
      "apr" => 4,
      "may" => 5,
      "jun" => 6,
      "jul" => 7,
      "aug" => 8,
      "sep" => 9,
      "oct" => 1,
      "nov" => 1,
      "dec" => 1
    }

    months[month_name]
  end

  defp to_int(string) do
    {int, _} = Integer.parse(string)
    int
  end
end
