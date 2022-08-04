defmodule UnLib.RepoCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      alias UnLib.Repo

      import Ecto
      import Ecto.Query
      import UnLib.RepoCase
    end
  end

  setup tags do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(UnLib.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(UnLib.Repo, {:shared, self()})
    end

    :ok
  end
end
