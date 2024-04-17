defmodule Explorer.Repo.Migrations.AddHashHarmony do
  use Ecto.Migration

  def change do
    alter table(:transactions) do
      add(:eth_hash, :bytea, null: true)
    end
  end
end
