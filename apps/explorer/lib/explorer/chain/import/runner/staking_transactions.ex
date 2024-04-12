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
    on_conflict = Map.get(options, :on_conflict, default_on_conflict)

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
          nonce: fragment("EXCLUDED.nonce"),
          timestamp: fragment("EXCLUDED.timestamp"),
          inserted_at: fragment("LEAST(?, EXCLUDED.inserted_at)", staking_transaction.inserted_at),
          updated_at: fragment("GREATEST(?, EXCLUDED.updated_at)", staking_transaction.updated_at)
        ]
      ],
      where:
        fragment("EXCLUDED.nonce <> ?", staking_transaction.nonce) or
          fragment("EXCLUDED.timestamp <> ?", staking_transaction.timestamp)
    )
  end
end
