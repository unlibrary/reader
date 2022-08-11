defmodule UnLib.Repo.Migrations.AddAccountsSources do
  use Ecto.Migration

  def change do
    create table(:users_sources, primary_key: false) do
      add :account_id, references(:users)
      add :source_url, references(:sources, column: :url, type: :string)
    end

    create unique_index(:users_sources, [:account_id, :source_url])
  end
end
