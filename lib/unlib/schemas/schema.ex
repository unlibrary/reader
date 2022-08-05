defmodule UnLib.Schema do
  @moduledoc false

  defmacro __using__(_) do
    quote do
      use TypedEctoSchema
      @primary_key {:id, Ecto.UUID, autogenerate: true}
      @foreign_key_type Ecto.UUID
    end
  end
end
