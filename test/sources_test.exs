defmodule SourcesTest do
  use ExUnit.Case, async: true
  use UnLib.RepoCase

  import UnLib.Fixtures

  alias UnLib.{Account, Source}
  alias UnLib.{Accounts, Sources}

  test "new/3 returns source struct" do
    {:ok, %Source{}} = Sources.new(valid_feed_url(), :rss)
  end

  test "new/3 validates url" do
    {:error, %Ecto.Changeset{}} = Sources.new("notanurl", :rss)
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
