defmodule UnLib.MixProject do
  use Mix.Project

  def project do
    [
      name: "Unlibrary",
      source_url: "https://github.com/unlibrary/reader",
      app: :unlib,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ecto_sql, "~> 3.0"},
      {:postgrex, ">= 0.0.0"},
      {:cloak, "1.1.1"},
      {:cloak_ecto, "~> 1.2"},
      {:jason, "~> 1.2"},
      {:bcrypt_elixir, "~> 2.3.0"},
      {:fast_rss, github: "RobinBoers/fast_rss"},
      {:ex_doc, "~> 0.24", only: :dev, runtime: false},
      {:the_big_username_blacklist, "~> 0.1.2"}
    ]
  end
end
