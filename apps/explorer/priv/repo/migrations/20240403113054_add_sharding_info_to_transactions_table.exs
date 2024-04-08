defmodule Explorer.Repo.Migrations.AddShardingInfoToTransactionsTable do
  use Ecto.Migration

  def change do
    alter table(:transactions) do
      add(:shard_id, :integer, null: true)
      add(:to_shard_id, :integer, null: true)
    end
  end
end
