defmodule Explorer.Chain.CSVExport.SmartContractsCsvExporter do
  @moduledoc """
  Exports smart contracts to a csv file.
  """

  alias Explorer.Chain.{SmartContract, Address}
  alias Explorer.Chain.CSVExport.Helper

  def export(from_period, to_period) do
    SmartContract.verified_contracts_by_date_range(from_period, to_period)
    |> to_csv_format()
    |> Helper.dump_to_stream()
  end

  defp to_csv_format(smart_contracts) do
    row_names = [
      "contract_address",
      "contract_name",
      "chain",
    ]
    chain_id = Application.get_env(:block_scout_web, :chain_id)
    smart_contracts_list =
      smart_contracts
      |> Stream.map(fn smart_contract ->
        [
          Address.checksum(smart_contract.address_hash),
          smart_contract.name,
          chain_id,
        ]
      end)

    Stream.concat([row_names], smart_contracts_list)
  end
end
