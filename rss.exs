# Demostrates use of the library

{:ok, account} = UnLib.Accounts.create("robijntje", "toor")
{:ok, account} = UnLib.Accounts.login("robijntje", "toor")

{:ok, source} = UnLib.Sources.new("https://stackoverflow.blog/feed/", :rss, "Stack Overflow")
{:ok, account} = UnLib.Sources.add(source, account)

UnLib.Feeds.check(source)
UnLib.Feeds.pull(source)
%UnLib.Feeds.Data{entries: []} = UnLib.Feeds.check(source)
