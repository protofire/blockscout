defmodule Explorer.Repo.Migrations.CreateStakingLogs do
  use Ecto.Migration

  def change do
    create table(:staking_logs, primary_key: false) do
      add(:data, :bytea, null: false)
      add(:index, :integer, null: false, primary_key: true)
      add(:block_number, :integer)

      add(:first_topic, :bytea, null: true)
      add(:second_topic, :bytea, null: true)
      add(:third_topic, :bytea, null: true)
      add(:fourth_topic, :bytea, null: true)

      timestamps(null: false, type: :utc_datetime_usec)

      add(:address_hash, references(:addresses, column: :hash, on_delete: :delete_all, type: :bytea), null: true)

      add(:block_hash, references(:blocks, column: :hash, type: :bytea), null: false, primary_key: true)

      add(
        :transaction_hash,
        references(:staking_transactions, column: :hash, on_delete: :delete_all, type: :bytea),
        null: false,
        primary_key: true
      )
    end

    create(index(:staking_logs, :address_hash))
    create(index(:staking_logs, :transaction_hash))

    create(index(:staking_logs, :index))
    create(index(:staking_logs, :first_topic))
    create(index(:staking_logs, :second_topic))
    create(index(:staking_logs, :third_topic))
    create(index(:staking_logs, :fourth_topic))
    create(unique_index(:staking_logs, [:transaction_hash, :index]))
  end
end
