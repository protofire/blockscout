defmodule Explorer.Repo.Migrations.CreateStakingTransactions do
  use Ecto.Migration

  def change do
    alter table(:addresses) do
      add(:staking_transactions_count, :integer, default: 0)
    end
  end
end
