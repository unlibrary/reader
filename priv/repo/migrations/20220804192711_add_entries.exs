defmodule UnLib.Repo.Migrations.AddEntries do
  use Ecto.Migration

  def change do
    create table(:entries) do
      add :date, :naive_datetime
      add :title, :string
      add :body, :text
      add :url, :string

      add :source_url, references(:sources)
    end
  end
end
