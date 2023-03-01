defmodule EntriesTest do
  use ExUnit.Case, async: true
  use UnLib.RepoCase

  import UnLib.Fixtures

  alias UnLib.{Entry, ParsedEntry}
  alias UnLib.{Accounts, Sources, Entries}

  test "ParsedEntry.from/1 converts parsed rss entry to struct" do
    rss_entry = %{
      updated: "Sat, 28 Jan 2023 17:05:40 +0100",
      title: "Smartphones verbieden in de klas: niet de oplossing",
      content: nil,
      description:
        "Ik zat gisteren een fragment van de avondshow van Arjen Lubach te kijken met de naam &ldquo;En nou is het afgelopen met telefoons in de klas&rdquo;. Ik moet zeggen dat ik het vaak met Arjen Lubach eens ben, maar dit stond toch echt lijnrecht tegenover mijn eigen mening. Het standpunt van Arjen is dat smartphones landelijk verboden zouden moeten worden op school. En ik ben het er niet (helemaal) mee eens.",
      url: "https://blog.geheimesite.nl/post/smartphones-in-de-klas/"
    }

    %ParsedEntry{date: date, title: title, body: body, url: url} = ParsedEntry.from(rss_entry)

    assert date == rss_entry.updated
    assert title == rss_entry.title
    assert body == rss_entry.description
    assert url == rss_entry.url
  end

  test "get/1 returns entry by id" do
    populate_db_with_entries()
    [%Entry{id: entry_id, title: entry_title} | _rest] = Entries.list()

    {:ok, %Entry{id: ^entry_id, title: ^entry_title}} = Entries.get(entry_id)
  end

  test "get/1 returns error for invalid id" do
    populate_db_with_entries()

    invalid_id = Ecto.UUID.generate()
    assert {:error, :entry_not_found} == Entries.get(invalid_id)
  end

  test "get_by_url/1 returns entry by url" do
    populate_db_with_entries()
    [%Entry{id: entry_id, url: entry_url, title: entry_title} | _rest] = Entries.list()

    {:ok, %Entry{id: ^entry_id, url: ^entry_url, title: ^entry_title}} =
      Entries.get_by_url(entry_url)
  end

  test "get_by_url/1 returns error for invalid URL" do
    populate_db_with_entries()

    invalid_url = "https://example.com/post/somebullshit"
    assert {:error, :entry_not_found} == Entries.get_by_url(invalid_url)
  end

  test "list_unread/1 lists entries for source or account" do
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
    assert Enum.empty?(source_entries)
  end

  test "prune/1 deletes read entries in source" do
    {:ok, source} = Sources.new(valid_feed_url(), :rss)

    populate_db_with_entries()
    source_entries = Entries.list(source)

    assert length(source_entries) == 5

    {:ok, %Entry{read?: true}} = UnLib.Entries.read(hd(source_entries))

    :ok = UnLib.Entries.prune(source)

    source_entries = Entries.list(source)
    assert length(source_entries) == 4
  end

  test "prune/1 deletes read entries in account" do
    {:ok, user} = Accounts.create("robijntje", valid_password())
    {:ok, source} = Sources.new(valid_feed_url(), :rss)

    {:ok, user} = Sources.add(source, user)
    assert length(user.sources) == 1

    populate_db_with_entries()
    user_entries = Entries.list(user)

    assert length(user_entries) == 5

    {:ok, %Entry{read?: true}} = UnLib.Entries.read(hd(user_entries))

    :ok = UnLib.Entries.prune(user)

    user_entries = Entries.list(user)
    assert length(user_entries) == 4
  end

  test "delete/1 deletes a single entry by id or entry struct" do
    {:ok, source} = Sources.new(valid_feed_url(), :rss)

    populate_db_with_entries()
    source_entries = Entries.list_unread(source)
    assert length(source_entries) == 5

    [entry1, entry2 | _rest] = source_entries
    :ok = Entries.delete(entry1)
    :ok = Entries.delete(entry2.id)

    source_entries = Entries.list(source)
    assert length(source_entries) == 3
  end

  test "delete_all/1 deletes all entries in source" do
    {:ok, source} = Sources.new(valid_feed_url(), :rss)

    populate_db_with_entries()
    source_entries = Entries.list(source)

    assert length(source_entries) == 5

    :ok = UnLib.Entries.delete_all(source)

    source_entries = Entries.list(source)
    assert Enum.empty?(source_entries) == true
  end

  test "delete_all/1 deletes all entries in account" do
    {:ok, user} = Accounts.create("robijntje", valid_password())
    {:ok, source} = Sources.new(valid_feed_url(), :rss)

    {:ok, user} = Sources.add(source, user)
    assert length(user.sources) == 1

    populate_db_with_entries()
    user_entries = Entries.list(user)

    assert length(user_entries) == 5

    :ok = UnLib.Entries.delete_all(user)

    user_entries = Entries.list(user)
    assert Enum.empty?(user_entries) == true
  end

  test "unread/1 marks entry as unread" do
    {:ok, source} = Sources.new(valid_feed_url(), :rss)

    populate_db_with_entries()
    source_entries = Entries.list_unread(source)
    assert length(source_entries) == 5

    entry = hd(source_entries)
    {:ok, entry} = Entries.read(entry)

    assert entry.read? == true

    {:ok, entry} = Entries.unread(entry)
    assert entry.read? == false

    :ok = UnLib.Entries.prune(source)

    source_entries = Entries.list(source)
    assert length(source_entries) == 5
  end

  test "unread_all/1 marks all entries as unread" do
    {:ok, source} = Sources.new(valid_feed_url(), :rss)

    populate_db_with_entries()
    source_entries = Entries.list_unread(source)
    assert length(source_entries) == 5

    entry = hd(source_entries)
    {:ok, entry} = Entries.read(entry)

    assert entry.read? == true

    :ok = Entries.unread_all(source)

    unread_entries = Entries.list_unread(source)
    assert length(unread_entries) == 5
  end
end
