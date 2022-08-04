defmodule UnLib.Schema do
  @moduledoc """
  This is a behavoir that can be used by schemas to use an autogenerated UUID as
  primary key and to use TypedEctoSchema.
  """

  defmacro __using__(_) do
    quote do
      use TypedEctoSchema
      @primary_key {:id, Ecto.UUID, autogenerate: true}
      @foreign_key_type Ecto.UUID
    end
  end
end
