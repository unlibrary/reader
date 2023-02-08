defmodule DateTimeTest do
  use ExUnit.Case, async: true
  use UnLib.RepoCase

  alias UnLib.{DateTime}

  test "now/0 returns NaiveDateTime struct" do
    %NaiveDateTime{} = DateTime.now()
  end

  test "human_datetime/0 takes an NaiveDateTime and formats it" do
    datetime = DateTime.now()
    datetime_string = DateTime.human_datetime(datetime)

    assert String.contains?(datetime_string, "/")
  end

  test "to_rfc822/1 and from_rfc822/1 work" do
    datetime = DateTime.now()
    rfc_822_datetime = DateTime.to_rfc822(datetime)

    assert DateTime.from_rfc822(rfc_822_datetime) == datetime
  end
end
