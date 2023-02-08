defmodule UnLib.Repo.Migrations.AddReadList do
  use Ecto.Migration

  def change do
    create table(:read_entries) do
      add :url, :string

      add :user_id, references(:users)
      add :source_id, references(:sources)
    end
  end
end
