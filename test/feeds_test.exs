defmodule FeedsTest do
  use ExUnit.Case, async: true
  use UnLib.RepoCase

  import UnLib.Fixtures

  alias UnLib.{Accounts, Sources, Feeds, Entries}

  test "pull/1 pulls a single source" do
    {:ok, source} = Sources.new(valid_feed_url(), :rss)

    Feeds.pull(source)

    source_entries = Entries.list_unread(source)
    assert length(source_entries) == 5
  end

  test "pull/1 pulls feeds for a single account" do
    {:ok, user} = Accounts.create("robijntje", valid_password())
    {:ok, source} = Sources.new(valid_feed_url(), :rss)

    {:ok, user} = Sources.add(source, user)
    assert length(user.sources) == 1

    Feeds.pull(user)

    user_entries = Entries.list_unread(user)
    assert length(user_entries) == 5
  end

  test "pull/0 pulls everything" do
    {:ok, _source} = Sources.new(valid_feed_url(), :rss)

    Feeds.pull()

    total_entries = Entries.list()
    assert length(total_entries) == 5
  end

  test "pull/0 errors on invalid URL" do
    {:ok, _source} = Sources.new(invalid_feed_url(), :rss, "AMAZING BLOG")

    data = Feeds.pull()

    assert hd(data).error == "could not download feed for AMAZING BLOG"

    total_entries = Entries.list()
    assert length(total_entries) == 0
  end

  test "pull/0 errors on 404 URL" do
    {:ok, _source} = Sources.new(non_existing_feed_url(), :rss, "AMAZING BLOG")

    data = Feeds.pull()

    assert hd(data).error == "could not download feed for AMAZING BLOG, got 404"

    total_entries = Entries.list()
    assert length(total_entries) == 0
  end
end
