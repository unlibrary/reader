defmodule UnLib.RepoCase do
  @moduledoc false
  use ExUnit.CaseTemplate

  using do
    quote do
      alias UnLib.Repo

      import Ecto
      import Ecto.Changeset
      import Ecto.Query
      import UnLib.RepoCase
    end
  end

  setup tags do
    pid = Ecto.Adapters.SQL.Sandbox.start_owner!(UnLib.Repo, shared: not tags[:async])
    on_exit(fn -> Ecto.Adapters.SQL.Sandbox.stop_owner(pid) end)

    :ok
  end
end
