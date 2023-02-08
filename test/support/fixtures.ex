defmodule UnLib.Fixtures do
  @moduledoc """
  Provides helpers for tests with often used values.

  These can now be changed easily: say, for example, we change the password requirements, we only need to update the password used in tests here. Not 600 variations of it in different test files.
  """

  def valid_password do
    "somepassword"
  end

  def valid_feed_url do
    "https://blog.geheimesite.nl/index.xml"
  end

  def invalid_feed_url do
    "http://localhost:3000/feed.xml"
  end

  def non_existing_feed_url do
    "https://blog.geheimesite.nl/bullshit.xml"
  end

  def populate_db_with_entries do
    {:ok, source} = UnLib.Sources.new(valid_feed_url(), :rss)
    data = UnLib.Feeds.Data.from(source)

    xml = File.read!("test/support/feed.xml")

    %UnLib.Feeds.Data{data | xml: xml}
    |> UnLib.Feeds.parse()
    |> UnLib.Feeds.filter()
    |> UnLib.Feeds.save()
  end
end
