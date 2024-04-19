defmodule Explorer.Repo.Migrations.AddGasUsageToStakingTransaction do
  use Ecto.Migration

  def change do
    alter table(:staking_transactions) do
      add(:cumulative_gas_used, :numeric, precision: 100, null: true)
      add(:gas_used, :numeric, precision: 100, null: true)
      add(:status, :integer, null: true)
    end
  end
end
