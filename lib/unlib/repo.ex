defmodule UnLib.Repo do
  @moduledoc """
  Handles database interactions.
  """
  use Ecto.Repo,
    otp_app: :unlib,
    adapter: Ecto.Adapters.Postgres
end
