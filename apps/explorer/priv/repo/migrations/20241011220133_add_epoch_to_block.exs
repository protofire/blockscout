defmodule Explorer.Repo.Migrations.AddEpochToBlock do
  use Ecto.Migration

  def change do
    alter table(:blocks) do
      add(:epoch, :bigint, null: true)
    end
  end
end
