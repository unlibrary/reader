defmodule UnLib.Application do
  @moduledoc false

  use Application

  @opts [strategy: :one_for_one, name: UnLib.Supervisor]

  @impl true
  def start(_type, _args) do
    children = [
      UnLib.Repo,
      UnLib.Vault,
      {Finch, name: UnLib.Finch}
    ]

    Supervisor.start_link(children, @opts)
  end
end
