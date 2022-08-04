defmodule UnLib.Repo.Migrations.AddEntries do
  use Ecto.Migration

  def change do
    create table(:entries) do
      add :date, :naive_datetime
      add :title, :string
      add :body, :text

      add :source_id, references(:sources)
    end
  end
end
