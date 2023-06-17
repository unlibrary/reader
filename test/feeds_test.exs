defmodule FeedsTest do
  use ExUnit.Case, async: true
  use UnLib.RepoCase

  import UnLib.Fixtures

  alias UnLib.{Accounts, Sources, Feeds, Entries}

  @amount_of_entries_to_save 20

  test "Feeds.Data.from generates Feeds.Data struct with source" do
    {:ok, source} = Sources.new(valid_feed_url(), :rss)

    %Feeds.Data{
      xml: nil,
      entries: [],
      source: ^source,
      error: nil
    } = Feeds.Data.from(source)
  end

  test "pull/1 pulls a single source" do
    {:ok, source} = Sources.new(valid_feed_url(), :rss)

    _data = Feeds.pull(source)

    source_entries = Entries.list_unread(source)
    assert length(source_entries) == @amount_of_entries_to_save
  end

  test "pull/1 pulls feeds for a single account" do
    {:ok, user} = Accounts.create("robijntje", valid_password())
    {:ok, source} = Sources.new(valid_feed_url(), :rss)

    {:ok, user} = Sources.add(source, user)
    assert length(user.sources) == 1

    _data = Feeds.pull(user)

    user_entries = Entries.list_unread(user)
    assert length(user_entries) == @amount_of_entries_to_save
  end

  test "pull/0 pulls everything" do
    {:ok, _source} = Sources.new(valid_feed_url(), :rss)

    _data = Feeds.pull()

    total_entries = Entries.list()
    assert length(total_entries) == @amount_of_entries_to_save
  end

  test "pull/0 errors on invalid URL" do
    {:ok, _source} = Sources.new(invalid_feed_url(), :rss, "AMAZING BLOG")

    data = Feeds.pull()

    assert hd(data).error == "could not download feed for AMAZING BLOG"

    total_entries = Entries.list()
    assert Enum.empty?(total_entries)
  end

  test "pull/0 errors on 404 URL" do
    {:ok, _source} = Sources.new(non_existing_feed_url(), :rss, "AMAZING BLOG")

    data = Feeds.pull()

    assert hd(data).error == "could not download feed for AMAZING BLOG, got 404"

    total_entries = Entries.list()
    assert Enum.empty?(total_entries)
  end

  test "pull skips entries already in db" do
    {:ok, source} = Sources.new(valid_feed_url(), :rss)

    _data = Feeds.pull(source)

    source_entries = Entries.list(source)
    assert length(source_entries) == @amount_of_entries_to_save

    _data = Feeds.pull(source)

    source_entries = Entries.list(source)
    assert length(source_entries) == @amount_of_entries_to_save
  end

  test "pull skips read entries" do
    {:ok, source} = Sources.new(valid_feed_url(), :rss)

    _data = Feeds.pull(source)

    source_entries = Entries.list(source)
    assert length(source_entries) == @amount_of_entries_to_save

    :ok = Entries.read_all(source)
    :ok = Entries.prune(source)

    source_entries = Entries.list(source)
    assert Enum.empty?(source_entries)

    _data = Feeds.pull(source)

    source_entries = Entries.list(source)
    assert Enum.empty?(source_entries)
  end

  test "pull skips read entries but pulls unread ones" do
    {:ok, source} = Sources.new(valid_feed_url(), :rss)

    _data = Feeds.pull(source)

    source_entries = Entries.list(source)
    assert length(source_entries) == @amount_of_entries_to_save

    entry = hd(source_entries)
    {:ok, _entry} = Entries.read(entry)

    :ok = Entries.delete_all(source)

    source_entries = Entries.list(source)
    assert Enum.empty?(source_entries)

    _data = Feeds.pull(source)

    source_entries = Entries.list(source)
    assert length(source_entries) == @amount_of_entries_to_save - 1
  end
end
