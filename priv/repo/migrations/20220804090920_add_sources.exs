defmodule UnLib.Repo.Migrations.AddSources do
  use Ecto.Migration

  def change do
    create table(:sources, primary_key: false) do
      add :url, :string, primary_key: true
      add :name, :string
      add :icon, :string
      add :type, :string
    end
  end
end
