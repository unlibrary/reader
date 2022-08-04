defmodule UnLib.Repo do
  use Ecto.Repo,
    otp_app: :unlib,
    adapter: Ecto.Adapters.Postgres
end
