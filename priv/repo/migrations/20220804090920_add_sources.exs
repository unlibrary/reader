defmodule UnLib.Repo.Migrations.AddSources do
  use Ecto.Migration

  def change do
    create table(:sources) do
      add :url, :string
      add :name, :string
      add :icon, :string
      add :type, :string
    end
  end
end
