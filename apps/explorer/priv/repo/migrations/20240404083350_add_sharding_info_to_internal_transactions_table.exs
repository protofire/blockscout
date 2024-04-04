defmodule Explorer.Repo.Migrations.AddShardingInfoToInternalTransactionsTable do
  use Ecto.Migration

  def change do
    alter table(:internal_transactions) do
      add(:shard_id, :integer, null: true)
      add(:to_shard_id, :integer, null: true)
    end
  end
end
