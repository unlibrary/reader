defmodule SourcesTest do
  use ExUnit.Case, async: true
  use UnLib.RepoCase

  import UnLib.Fixtures

  alias UnLib.{Account, Source}
  alias UnLib.{Accounts, Sources}

  @amount_of_entries_to_save 20

  test "new/3 returns source struct" do
    {:ok, %Source{}} = Sources.new(valid_feed_url(), :rss)
  end

  test "new/3 validates url" do
    {:error, %Ecto.Changeset{}} = Sources.new("notanurl", :rss)
  end

  test "get/1 works and preloads entries" do
    {:ok, %Source{id: id, name: "ye"}} = Sources.new(valid_feed_url(), :rss, "ye")

    {:ok, source} = Sources.get(id)
    assert source.entries == []

    assert {:error, :source_not_found} == Sources.get(Ecto.UUID.generate())
  end

  test "update/4 updates a source" do
    {:ok, %Source{id: id, name: "ye"} = s} = Sources.new(valid_feed_url(), :rss, "ye")
    {:ok, %Source{id: ^id, name: "yo"}} = Sources.update(s, valid_feed_url(), :rss, "yo")
  end

  test "new/3 updates source if it exists and get_by_url/1 works" do
    {:ok, %Source{id: id, name: "ye"} = s} = Sources.new(valid_feed_url(), :rss, "ye")

    {:ok, source} = Sources.get_by_url(valid_feed_url())
    assert source == s

    {:ok, %Source{id: ^id, name: "yo"} = s} = Sources.new(valid_feed_url(), :rss, "yo")

    {:ok, source} = Sources.get_by_url(valid_feed_url())
    assert source == s
  end

  test "get_by_url/1 returns error if source doesn't exist" do
    assert {:error, :source_not_found} == Sources.get_by_url("someotherurl")
  end

  test "list/0 lists all sources and list/1 lists sources in an account" do
    username = "robijntje"
    {:ok, user} = Accounts.create(username, valid_password())

    for x <- 0..9 do
      Sources.new("#{valid_feed_url()}#{x}", :rss, "#{x}")
    end

    for x <- 0..4 do
      {:ok, source} = Sources.new("#{valid_feed_url()}#{x}", :rss)
      {:ok, _user} = Sources.add(source, user)
    end

    sources = Sources.list()
    assert is_list(sources)
    assert length(sources) == 10

    sources = Sources.list(user)
    assert is_list(sources)
    assert length(sources) == 5
  end

  test "add/2 adds source to account and remove/2 removes it" do
    {:ok, %Account{sources: []} = user} = Accounts.create("Robijntje", valid_password())

    {:ok, source} = Sources.new(valid_feed_url(), :rss)
    {:ok, user} = Sources.add(source, user)

    assert user.sources == [source]

    {:ok, user} = Sources.remove(source, user)

    assert user.sources == []
  end
end
