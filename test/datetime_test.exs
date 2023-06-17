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

  test "to_rfc2822/1 and from_rfc2822/1 work" do
    datetime = DateTime.now()
    rfc_2822_datetime = DateTime.to_rfc2822(datetime)

    assert DateTime.from_rfc2822(rfc_2822_datetime) == datetime
  end

  test "to_rfc3339/1 and from_rfc3339/1 work" do
    datetime = DateTime.now()
    rfc_3339_datetime = DateTime.to_rfc3339(datetime)

    assert DateTime.from_rfc3339(rfc_3339_datetime) == datetime
  end
end
