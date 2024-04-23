defmodule BlockScoutWeb.API.V2.StakingTransactionView do
  use BlockScoutWeb, :view

  alias BlockScoutWeb.API.V2.{Helper}
  alias Explorer.Chain.{StakingLog, StakingTransaction}

  @api_true [api?: true]

  def render("staking_transaction.json", %{transaction: transaction}) do
    prepare_transaction(transaction)
  end

  def render("staking_transactions.json", %{transactions: transactions, next_page_params: next_page_params}) do
    %{
      "items" => Enum.map(transactions, &prepare_transaction/1),
      "next_page_params" => next_page_params
    }
  end

  def render("staking_transactions.json", %{transactions: transactions}) do
    Enum.map(transactions, &prepare_transaction/1)
  end

  def render("logs.json", %{logs: logs, next_page_params: next_page_params, tx_hash: tx_hash}) do
    decoded_logs = decode_logs(logs, false)

    %{
      "items" =>
        logs |> Enum.zip(decoded_logs) |> Enum.map(fn {log, decoded_log} -> prepare_log(log, tx_hash, decoded_log) end),
      "next_page_params" => next_page_params
    }
  end

  def render("logs.json", %{logs: logs, next_page_params: next_page_params}) do
    decoded_logs = decode_logs(logs, false)

    %{
      "items" =>
        logs
        |> Enum.zip(decoded_logs)
        |> Enum.map(fn {log, decoded_log} -> prepare_log(log, log.transaction, decoded_log) end),
      "next_page_params" => next_page_params
    }
  end

  defp prepare_transaction(transaction) do
    %{
      hash: transaction.hash,
      nonce: transaction.nonce,
      timestamp: transaction.timestamp,
      gas_price: transaction.gas_price,
      gas: transaction.gas,
      gas_used: transaction.gas_used,
      cumulative_gas_used: transaction.cumulative_gas_used,
      status: transaction.status,
      type: transaction.type,
      block: transaction.block_number,
      transaction_index: transaction.transaction_index,
      from: Helper.address_with_info(nil, transaction.from_address, transaction.from_address_hash, false),
      msg_validator_address: transaction.msg_validator_address,
      msg_name: transaction.msg_name,
      msg_commission_rate: transaction.msg_commission_rate,
      msg_max_commission_rate: transaction.msg_max_commission_rate,
      msg_max_change_rate: transaction.msg_max_change_rate,
      msg_min_self_delegation: transaction.msg_min_self_delegation,
      msg_max_total_delegation: transaction.msg_max_total_delegation,
      msg_amount: transaction.msg_amount,
      msg_website: transaction.msg_website,
      msg_identity: transaction.msg_identity,
      msg_security_contact: transaction.msg_security_contact,
      msg_details: transaction.msg_details,
      msg_slot_pub_keys: transaction.msg_slot_pub_keys,
      msg_delegator_address: transaction.msg_delegator_address,
      msg_slot_pub_key_to_add: transaction.msg_slot_pub_key_to_add,
      msg_slot_pub_key_to_remove: transaction.msg_slot_pub_key_to_remove
    }
  end

  @spec decode_logs([StakingLog.t()], boolean) :: [tuple]
  def decode_logs(logs, skip_sig_provider?) do
    {result, _, _} =
      Enum.reduce(logs, {[], %{}, %{}}, fn log, {results, contracts_acc, events_acc} ->
        {result, contracts_acc, events_acc} =
          StakingLog.decode(
            log,
            %StakingTransaction{hash: log.transaction_hash},
            @api_true,
            skip_sig_provider?,
            contracts_acc,
            events_acc
          )

        {[format_decoded_log_input(result) | results], contracts_acc, events_acc}
      end)

    Enum.reverse(result)
  end

  def prepare_log(log, transaction_or_hash, decoded_log, tags_for_address_needed? \\ false) do
    decoded = process_decoded_log(decoded_log)

    %{
      "tx_hash" => get_tx_hash(transaction_or_hash),
      "address" => Helper.address_with_info(nil, log.address, log.address_hash, tags_for_address_needed?),
      "topics" => [
        log.first_topic,
        log.second_topic,
        log.third_topic,
        log.fourth_topic
      ],
      "data" => log.data,
      "index" => log.index,
      "decoded" => decoded,
      "block_number" => log.block_number,
      "block_hash" => log.block_hash
    }
  end

  @spec format_decoded_input(any()) :: nil | map() | tuple()
  def format_decoded_input({:error, _, []}), do: nil
  def format_decoded_input({:error, _, candidates}), do: Enum.at(candidates, 0)
  def format_decoded_input({:ok, _identifier, _text, _mapping} = decoded), do: decoded
  def format_decoded_input(_), do: nil

  defp format_decoded_log_input({:error, :could_not_decode}), do: nil
  defp format_decoded_log_input({:ok, _method_id, _text, _mapping} = decoded), do: decoded
  defp format_decoded_log_input({:error, _, candidates}), do: Enum.at(candidates, 0)

  defp get_tx_hash(%StakingTransaction{} = tx), do: to_string(tx.hash)
  defp get_tx_hash(hash), do: to_string(hash)

  defp process_decoded_log(decoded_log) do
    case decoded_log do
      {:ok, method_id, text, mapping} ->
        render(__MODULE__, "decoded_log_input.json", method_id: method_id, text: text, mapping: mapping)

      _ ->
        nil
    end
  end
end
