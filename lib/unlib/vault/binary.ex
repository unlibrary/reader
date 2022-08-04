defmodule UnLib.Vault.Binary do
  @moduledoc """
  Ecto type for saving encrypted `Cloak` data to the database.
  """
  use Cloak.Ecto.Binary, vault: UnLib.Vault

  @type t() :: Cloak.Ecto.Binary
end
