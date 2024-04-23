defmodule Explorer.Repo.Migrations.CreateStakingTransactions do
  use Ecto.Migration

  def change do
    create table(:staking_transactions, primary_key: false) do
      add(:hash, :bytea, null: false, primary_key: true)
      add(:nonce, :integer, null: false)
      # `null` when a pending transaction
      add(:block_hash, references(:blocks, column: :hash, on_delete: :delete_all, type: :bytea), null: true)
      # `null` when a pending transaction
      add(:block_number, :integer, null: true)
      # `null` when a pending transaction
      add(:transaction_index, :integer, null: true)
      add(:timestamp, :utc_datetime_usec, null: false)
      add(:from_address_hash, references(:addresses, column: :hash, on_delete: :delete_all, type: :bytea), null: false)
      add(:value, :numeric, precision: 100, null: true)
      add(:gas_price, :numeric, precision: 100, null: false)
      add(:gas, :numeric, precision: 100, null: false)
      add(:v, :numeric, precision: 100, null: false)
      add(:r, :numeric, precision: 100, null: false)
      add(:s, :numeric, precision: 100, null: false)

      add(:type, :integer, null: false)

      # msg fields
      add(:msg_validator_address, :string, null: true)
      add(:msg_name, :string, null: true)
      add(:msg_commission_rate, :numeric, precision: 100, null: true)
      add(:msg_max_commission_rate, :numeric, precision: 100, null: true)
      add(:msg_max_change_rate, :numeric, precision: 100, null: true)
      add(:msg_min_self_delegation, :numeric, precision: 100, null: true)
      add(:msg_max_total_delegation, :numeric, precision: 100, null: true)
      add(:msg_amount, :numeric, precision: 100, null: true)
      add(:msg_website, :string, null: true)
      add(:msg_identity, :string, null: true)
      add(:msg_security_contact, :string, null: true)
      add(:msg_details, :string, null: true)
      add(:msg_slot_pub_keys, {:array, :string}, null: true)
      add(:msg_delegator_address, :string, null: true)
      add(:msg_slot_pub_key_to_add, :string, null: true)
      add(:msg_slot_pub_key_to_remove, :string, null: true)

      timestamps()
    end

    create(
      constraint(
        :staking_transactions,
        :pending_block_number,
        check: "block_hash IS NOT NULL OR block_number IS NULL"
      )
    )

    create(
      constraint(
        :staking_transactions,
        :pending_transaction_index,
        check: "block_hash IS NOT NULL OR transaction_index IS NULL"
      )
    )

    create(index(:staking_transactions, :block_hash))

    create(index(:staking_transactions, :inserted_at))
    create(index(:staking_transactions, :updated_at))

    create(index(:staking_transactions, :type))

    create(unique_index(:staking_transactions, [:block_hash, :transaction_index]))
  end
end
