defmodule EntriesTest do
  use ExUnit.Case, async: true
  use UnLib.RepoCase

  import UnLib.Fixtures

  alias UnLib.{Entry}
  alias UnLib.{Accounts, Sources, Entries}

  test "list_unread/1 lists entries for source & account" do
    {:ok, user} = Accounts.create("robijntje", valid_password())
    {:ok, source} = Sources.new(valid_feed_url(), :rss)

    populate_db_with_entries()
    source_entries = Entries.list_unread(source)

    assert length(source_entries) == 5

    {:ok, user} = Sources.add(source, user)
    user_entries = Entries.list_unread(user)

    assert source_entries == user_entries
  end

  test "list_unread/1 skips read items" do
    {:ok, user} = Accounts.create("robijntje", valid_password())
    {:ok, source} = Sources.new(valid_feed_url(), :rss)

    populate_db_with_entries()
    source_entries = Entries.list_unread(source)

    assert length(source_entries) == 5

    {:ok, %Entry{read?: true}} = UnLib.Entries.read(hd(source_entries))

    source_entries = Entries.list_unread(source)
    assert length(source_entries) == 4

    {:ok, user} = Sources.add(source, user)
    user_entries = Entries.list_unread(user)

    assert source_entries == user_entries
  end

  test "list/1 doens't skip read items" do
    {:ok, user} = Accounts.create("robijntje", valid_password())
    {:ok, source} = Sources.new(valid_feed_url(), :rss)

    populate_db_with_entries()
    source_entries = Entries.list_unread(source)

    assert length(source_entries) == 5

    {:ok, %Entry{read?: true}} = UnLib.Entries.read(hd(source_entries))

    source_entries = Entries.list(source)
    assert length(source_entries) == 5

    {:ok, user} = Sources.add(source, user)
    user_entries = Entries.list(user)

    assert source_entries == user_entries
  end

  test "read_all/1 reads all entries" do
    {:ok, source} = Sources.new(valid_feed_url(), :rss)

    populate_db_with_entries()
    source_entries = Entries.list(source)

    assert length(source_entries) == 5

    :ok = UnLib.Entries.read_all(source)

    source_entries = Entries.list_unread(source)
    assert length(source_entries) == 0
  end

  test "prune/1 deletes read items" do
    {:ok, source} = Sources.new(valid_feed_url(), :rss)

    populate_db_with_entries()
    source_entries = Entries.list(source)

    assert length(source_entries) == 5

    {:ok, %Entry{read?: true}} = UnLib.Entries.read(hd(source_entries))

    :ok = UnLib.Entries.prune(source)

    source_entries = Entries.list(source)
    assert length(source_entries) == 4
  end

  test "prune_all/1 deletes all items" do
    {:ok, source} = Sources.new(valid_feed_url(), :rss)

    populate_db_with_entries()
    source_entries = Entries.list(source)

    assert length(source_entries) == 5

    :ok = UnLib.Entries.prune_all(source)

    source_entries = Entries.list(source)
    assert Enum.empty?(source_entries) == true
  end
end
