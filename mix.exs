defmodule UnLib.MixProject do
  use Mix.Project

  @mix_env Mix.env()

  def project do
    [
      name: "Unlibrary",
      source_url: "https://github.com/unlibrary/reader",
      app: :unlib,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: @mix_env == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      deps: deps() ++ test_deps(),
      aliases: aliases()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {UnLib.Application, []}
    ]
  end

  defp deps do
    [
      {:ecto_sql, "~> 3.0"},
      {:postgrex, ">= 0.0.0"},
      {:typed_ecto_schema, "~> 0.4.1", runtime: false},
      {:cloak, "1.1.1"},
      {:cloak_ecto, "~> 1.2"},
      {:jason, "~> 1.2"},
      {:finch, "~> 0.13"},
      {:bcrypt_elixir, "~> 2.3.0"},
      {:fast_rss, github: "RobinBoers/fast_rss"},
      {:ex_doc, "~> 0.24", only: :dev, runtime: false},
      {:the_big_username_blacklist, "~> 0.1.2"}
    ]
  end

  defp test_deps do
    [
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.1", only: [:dev], runtime: false},
      {:ex_check, "~> 0.14.0", only: [:dev], runtime: false}
    ]
  end

  defp aliases do
    [
      setup: ["deps.get", "ecto.setup"],
      translate: ["gettext.extract", "gettext.merge priv/gettext --no-fuzzy"],
      "ecto.setup": ["ecto.create", "ecto.migrate"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]
end
