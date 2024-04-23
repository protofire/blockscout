defmodule Explorer.Chain.Import.Runner.StakingLogs do
  @moduledoc """
  Bulk imports `t:Explorer.Chain.Log.t/0`.
  """

  require Ecto.Query

  alias Ecto.{Changeset, Multi, Repo}
  alias Explorer.Chain.{Import, StakingLog}
  alias Explorer.Prometheus.Instrumenter

  import Ecto.Query, only: [from: 2]

  @behaviour Import.Runner

  # milliseconds
  @timeout 60_000

  @type imported :: [StakingLog.t()]

  @impl Import.Runner
  def ecto_schema_module, do: StakingLog

  @impl Import.Runner
  def option_key, do: :staking_logs

  @impl Import.Runner
  def imported_table_row do
    %{
      value_type: "[#{ecto_schema_module()}.t()]",
      value_description: "List of `t:#{ecto_schema_module()}.t/0`s"
    }
  end

  @impl Import.Runner
  def run(multi, changes_list, %{timestamps: timestamps} = options) do
    insert_options =
      options
      |> Map.get(option_key(), %{})
      |> Map.take(~w(on_conflict timeout)a)
      |> Map.put_new(:timeout, @timeout)
      |> Map.put(:timestamps, timestamps)

    Multi.run(multi, :staking_logs, fn repo, _ ->
      Instrumenter.block_import_stage_runner(
        fn -> insert(repo, changes_list, insert_options) end,
        :block_referencing,
        :staking_logs,
        :staking_logs
      )
    end)
  end

  @impl Import.Runner
  def timeout, do: @timeout

  @spec insert(Repo.t(), [map()], %{
          optional(:on_conflict) => Import.Runner.on_conflict(),
          required(:timeout) => timeout,
          required(:timestamps) => Import.timestamps()
        }) ::
          {:ok, [StakingLog.t()]}
          | {:error, [Changeset.t()]}
  defp insert(repo, changes_list, %{timeout: timeout, timestamps: timestamps} = options) when is_list(changes_list) do
    on_conflict = Map.get_lazy(options, :on_conflict, &default_on_conflict/0)

    # Enforce Log ShareLocks order (see docs: sharelocks.md)
    ordered_changes_list = Enum.sort_by(changes_list, &{&1.transaction_hash, &1.block_hash, &1.index})

    {:ok, _} =
      Import.insert_changes_list(
        repo,
        ordered_changes_list,
        conflict_target: [:transaction_hash, :index, :block_hash],
        on_conflict: on_conflict,
        for: StakingLog,
        returning: true,
        timeout: timeout,
        timestamps: timestamps
      )
  end

  defp default_on_conflict do
    from(
      log in StakingLog,
      update: [
        set: [
          address_hash: fragment("EXCLUDED.address_hash"),
          data: fragment("EXCLUDED.data"),
          first_topic: fragment("EXCLUDED.first_topic"),
          second_topic: fragment("EXCLUDED.second_topic"),
          third_topic: fragment("EXCLUDED.third_topic"),
          fourth_topic: fragment("EXCLUDED.fourth_topic"),
          # Don't update `index` as it is part of the composite primary key and used for the conflict target
          # Don't update `transaction_hash` as it is part of the composite primary key and used for the conflict target
          inserted_at: fragment("LEAST(?, EXCLUDED.inserted_at)", log.inserted_at),
          updated_at: fragment("GREATEST(?, EXCLUDED.updated_at)", log.updated_at)
        ]
      ],
      where:
        fragment(
          "(EXCLUDED.address_hash, EXCLUDED.data, EXCLUDED.first_topic, EXCLUDED.second_topic, EXCLUDED.third_topic, EXCLUDED.fourth_topic) IS DISTINCT FROM (?, ?, ?, ?, ?, ?)",
          log.address_hash,
          log.data,
          log.first_topic,
          log.second_topic,
          log.third_topic,
          log.fourth_topic
        )
    )
  end
end