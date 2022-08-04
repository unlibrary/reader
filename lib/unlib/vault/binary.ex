defmodule UnLib.Vault.Binary do
  use Cloak.Ecto.Binary, vault: UnLib.Vault

  @type t() :: Cloak.Ecto.Binary
end
