defmodule Explorer.Chain.Import.Runner.StakingTransactions do
  @moduledoc """
  Bulk imports `t:Explorer.Chain.StakingTransactions.t/0`.
  """

  require Ecto.Query
  require Logger

  alias Explorer.Chain.{Import}
  alias Ecto.{Changeset, Multi, Repo}
  alias Explorer.Chain.{StakingTransaction}
  alias Explorer.Chain.Import.Runner
  alias Explorer.Prometheus.Instrumenter

  import Ecto.Query

  @behaviour Runner

  @timeout 60_000

  @type imported :: [StakingTransaction.t()]

  @impl Runner
  def ecto_schema_module, do: StakingTransaction

  @impl Runner
  def option_key, do: :staking_transactions

  @impl Runner
  def imported_table_row do
    %{
      value_type: "[#{ecto_schema_module()}.t()]",
      value_description: "List of `t:#{ecto_schema_module()}.t/0`s"
    }
  end

  @impl Runner
  def run(multi, changes_list, %{timestamps: timestamps} = options) do
    insert_options =
      options
      |> Map.get(option_key(), %{})
      |> Map.take(~w(on_conflict timeout)a)
      |> Map.put_new(:timeout, @timeout)
      |> Map.put(:timestamps, timestamps)

    # Enforce ShareLocks tables order (see docs: sharelocks.md)
    multi
    |> Multi.run(:staking_transactions, fn repo, _ ->
      Instrumenter.block_import_stage_runner(
        fn -> insert(repo, changes_list, insert_options) end,
        :block_referencing,
        :staking_transactions,
        :staking_transactions
      )
    end)
  end

  @impl Runner
  def timeout, do: @timeout

  @spec insert(Repo.t(), [map()], %{
          optional(:on_conflict) => Runner.on_conflict(),
          required(:timeout) => timeout,
          required(:timestamps) => Import.timestamps()
        }) :: {:ok, [StakingTransaction.t()]} | {:error, [Changeset.t()]}
  defp insert(repo, changes_list, %{timeout: timeout, timestamps: timestamps} = options) when is_list(changes_list) do
    on_conflict = Map.get_lazy(options, :on_conflict, &default_on_conflict/0)

    # Enforce Transaction ShareLocks order (see docs: sharelocks.md)
    ordered_changes_list = Enum.sort_by(changes_list, & &1.hash)

    Import.insert_changes_list(
      repo,
      ordered_changes_list,
      conflict_target: :hash,
      on_conflict: on_conflict,
      for: StakingTransaction,
      returning: true,
      timeout: timeout,
      timestamps: timestamps
    )
  end

  defp default_on_conflict do
    from(
      staking_transaction in StakingTransaction,
      update: [
        set: [
          block_hash: fragment("EXCLUDED.block_hash"),
          block_number: fragment("EXCLUDED.block_number"),
          transaction_index: fragment("EXCLUDED.transaction_index"),
          from_address_hash: fragment("EXCLUDED.from_address_hash"),
          gas: fragment("EXCLUDED.gas"),
          gas_price: fragment("EXCLUDED.gas_price"),
          r: fragment("EXCLUDED.r"),
          s: fragment("EXCLUDED.s"),
          v: fragment("EXCLUDED.v"),
          type: fragment("EXCLUDED.type"),
          nonce: fragment("EXCLUDED.nonce"),
          timestamp: fragment("EXCLUDED.timestamp"),
          msg_validator_address: fragment("EXCLUDED.msg_validator_address"),
          msg_name: fragment("EXCLUDED.msg_name"),
          msg_commission_rate: fragment("EXCLUDED.msg_commission_rate"),
          msg_max_commission_rate: fragment("EXCLUDED.msg_max_commission_rate"),
          msg_max_change_rate: fragment("EXCLUDED.msg_max_change_rate"),
          msg_min_self_delegation: fragment("EXCLUDED.msg_min_self_delegation"),
          msg_max_total_delegation: fragment("EXCLUDED.msg_max_total_delegation"),
          msg_amount: fragment("EXCLUDED.msg_amount"),
          msg_website: fragment("EXCLUDED.msg_website"),
          msg_identity: fragment("EXCLUDED.msg_identity"),
          msg_security_contact: fragment("EXCLUDED.msg_security_contact"),
          msg_details: fragment("EXCLUDED.msg_details"),
          msg_slot_pub_keys: fragment("EXCLUDED.msg_slot_pub_keys"),
          msg_delegator_address: fragment("EXCLUDED.msg_delegator_address"),
          msg_slot_pub_key_to_add: fragment("EXCLUDED.msg_slot_pub_key_to_add"),
          msg_slot_pub_key_to_remove: fragment("EXCLUDED.msg_slot_pub_key_to_remove"),
          gas_used: fragment("EXCLUDED.gas_used"),
          cumulative_gas_used: fragment("EXCLUDED.cumulative_gas_used"),
          status: fragment("EXCLUDED.status"),
          inserted_at: fragment("LEAST(?, EXCLUDED.inserted_at)", staking_transaction.inserted_at),
          updated_at: fragment("GREATEST(?, EXCLUDED.updated_at)", staking_transaction.updated_at)
        ]
      ],
      where:
        fragment(
          "(EXCLUDED.block_hash, EXCLUDED.block_number, EXCLUDED.transaction_index, EXCLUDED.from_address_hash, EXCLUDED.gas, EXCLUDED.gas_price, EXCLUDED.r, EXCLUDED.s, EXCLUDED.v, EXCLUDED.type, EXCLUDED.nonce, EXCLUDED.timestamp, EXCLUDED.msg_validator_address, EXCLUDED.msg_name, EXCLUDED.msg_commission_rate, EXCLUDED.msg_max_commission_rate, EXCLUDED.msg_max_change_rate, EXCLUDED.msg_min_self_delegation, EXCLUDED.msg_max_total_delegation, EXCLUDED.msg_amount, EXCLUDED.msg_website, EXCLUDED.msg_identity, EXCLUDED.msg_security_contact, EXCLUDED.msg_details, EXCLUDED.msg_slot_pub_keys, EXCLUDED.msg_delegator_address, EXCLUDED.msg_slot_pub_key_to_add, EXCLUDED.msg_slot_pub_key_to_remove, EXCLUDED.gas_used, EXCLUDED.cumulative_gas_used, EXCLUDED.status) IS DISTINCT FROM (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ? ,?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
          staking_transaction.block_hash,
          staking_transaction.block_number,
          staking_transaction.transaction_index,
          staking_transaction.from_address_hash,
          staking_transaction.gas,
          staking_transaction.gas_price,
          staking_transaction.r,
          staking_transaction.s,
          staking_transaction.v,
          staking_transaction.type,
          staking_transaction.nonce,
          staking_transaction.timestamp,
          staking_transaction.msg_validator_address,
          staking_transaction.msg_name,
          staking_transaction.msg_commission_rate,
          staking_transaction.msg_max_commission_rate,
          staking_transaction.msg_max_change_rate,
          staking_transaction.msg_min_self_delegation,
          staking_transaction.msg_max_total_delegation,
          staking_transaction.msg_amount,
          staking_transaction.msg_website,
          staking_transaction.msg_identity,
          staking_transaction.msg_security_contact,
          staking_transaction.msg_details,
          staking_transaction.msg_slot_pub_keys,
          staking_transaction.msg_delegator_address,
          staking_transaction.msg_slot_pub_key_to_add,
          staking_transaction.msg_slot_pub_key_to_remove,
          staking_transaction.gas_used,
          staking_transaction.cumulative_gas_used,
          staking_transaction.status
        )
    )
  end
end
