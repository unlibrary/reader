import Config

config :unlib, UnLib.Repo,
  database: "undb_test",
  hostname: "localhost",
  username: "postgres",
  password: "postgres",
  pool: Ecto.Adapters.SQL.Sandbox

config :bcrypt_elixir, :log_rounds, 1
