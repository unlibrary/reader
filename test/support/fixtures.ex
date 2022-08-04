defmodule UnLib.Fixtures do
  @moduledoc """
  Provides helpers for tests with often used values.

  These can now be changed easily: say, for example, we change the password requirements, we only need to update the password used in tests here. Not 600 variations of it in different test files.
  """

  def valid_password do
    "somepassword"
  end

  def valid_feed_url do
    "https://stackoverflow.blog/newsletter/feed"
  end
end
