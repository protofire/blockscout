defmodule EthereumJSONRPC.StakingTransaction do
  @moduledoc """
  Staking transaction module
  https://docs.harmony.one/home/developers/api/methods/transaction-related-methods/hmy_getstakingtransactionbyhash

  included in [`hmy_getBlockByHash] (https://docs.harmony.one/home/developers/api/methods/transaction-related-methods/hmy_getblockbyhash)
  and [`hmy_getBlockByNumber] (https://docs.harmony.one/home/developers/api/methods/transaction-related-methods/hmy_getblockbynumber)
  """

  import EthereumJSONRPC, only: [quantity_to_integer: 1, timestamp_to_datetime: 1]
  import EthereumJSONRPC.Utility.Bech, only: [decode_bech_32_if_exist: 2, decode_bech_32: 1]

  alias EthereumJSONRPC

  @type elixir :: %{
          String.t() =>
            EthereumJSONRPC.address() | EthereumJSONRPC.hash() | String.t() | non_neg_integer() | DateTime.t() | nil
        }

  @type t :: %{
          String.t() =>
            EthereumJSONRPC.address() | EthereumJSONRPC.hash() | EthereumJSONRPC.quantity() | String.t() | nil
        }

  @type params :: %{
          hash: EthereumJSONRPC.hash(),
          nonce: non_neg_integer(),
          block_hash: EthereumJSONRPC.hash(),
          block_number: non_neg_integer(),
          transaction_index: non_neg_integer(),
          timestamp: DateTime.t(),
          from_address_hash: EthereumJSONRPC.address(),
          value: non_neg_integer(),
          gas_price: non_neg_integer(),
          gas: non_neg_integer(),
          v: non_neg_integer(),
          r: non_neg_integer(),
          s: non_neg_integer(),
          type: String.t(),
          msg_validator_address: String.t(),
          msg_name: String.t(),
          msg_commission_rate: non_neg_integer(),
          msg_max_commission_rate: non_neg_integer(),
          msg_max_change_rate: non_neg_integer(),
          msg_min_self_delegation: non_neg_integer(),
          msg_max_total_delegation: non_neg_integer(),
          msg_amount: non_neg_integer(),
          msg_website: String.t(),
          msg_identity: String.t(),
          msg_security_contact: String.t(),
          msg_details: String.t(),
          msg_slot_pub_keys: [String.t()],
          msg_delegator_address: String.t(),
          msg_slot_pub_key_to_add: String.t(),
          msg_slot_pub_key_to_remove: String.t()
        }

  @spec elixir_to_params(elixir) :: params

  def elixir_to_params(
        %{
          "hash" => hash,
          "nonce" => nonce,
          "blockHash" => block_hash,
          "blockNumber" => block_number,
          "transactionIndex" => transaction_index,
          "timestamp" => timestamp,
          "from" => from_address_hash,
          "gasPrice" => gas_price,
          "gas" => gas,
          "v" => v,
          "r" => r,
          "s" => s,
          "type" => type
        } = transaction
      ) do
    result = %{
      hash: hash,
      nonce: nonce,
      block_hash: block_hash,
      block_number: block_number,
      transaction_index: transaction_index,
      timestamp: timestamp,
      from_address_hash: from_address_hash,
      gas_price: gas_price,
      gas: gas,
      v: v,
      r: r,
      s: s,
      type: type
    }

    put_if_present(transaction, result, [
      {"value", "value"}
    ])
    |> put_msg(transaction)
  end

  def to_elixir(transaction, block_timestamp \\ nil)

  def to_elixir(transaction, block_timestamp) when is_map(transaction) do
    initial = (block_timestamp && %{"block_timestamp" => block_timestamp}) || %{}
    Enum.into(transaction, initial, &entry_to_elixir/1)
  end

  def to_elixir(transaction, _block_timestamp) when is_binary(transaction) do
    nil
  end

  def params_to_hash(%{hash: hash}), do: hash

  defp put_msg(result, transaction) do
    msg = Map.get(transaction, "msg")

    case msg do
      nil ->
        result

      _ ->
        put_if_present(msg, result, [
          {"validatorAddress", :msg_validator_address},
          {"name", :msg_name},
          {"commissionRate", :msg_commission_rate},
          {"maxCommissionRate", :msg_max_commission_rate},
          {"maxChangeRate", :msg_max_change_rate},
          {"minSelfDelegation", :msg_min_self_delegation},
          {"maxTotalDelegation", :msg_max_total_delegation},
          {"amount", :msg_amount},
          {"website", :msg_website},
          {"identity", :msg_identity},
          {"securityContact", :msg_security_contact},
          {"details", :msg_details},
          {"slotPubKeys", :msg_slot_pub_keys},
          {"delegatorAddress", :msg_delegator_address},
          {"slotPubKeyToAdd", :msg_slot_pub_key_to_add},
          {"slotPubKeyToRemove", :msg_slot_pub_key_to_remove}
        ])
    end
  end

  defp entry_to_elixir({key, value})
       when key in ~w(hash blockHash type),
       do: {key, value}

  defp entry_to_elixir({key, value})
       when key in ~w(msg) do
    {key,
     value
     |> decode_bech_32_if_exist("validatorAddress")
     |> decode_bech_32_if_exist("slotPubKeyToAdd")
     |> decode_bech_32_if_exist("slotPubKeyToRemove")
     |> decode_bech_32_if_exist("delegatorAddress")
     |> quantity_to_integer_if_exist("commissionRate")
     |> quantity_to_integer_if_exist("maxCommissionRate")
     |> quantity_to_integer_if_exist("maxChangeRate")
     |> quantity_to_integer_if_exist("minSelfDelegation")
     |> quantity_to_integer_if_exist("maxTotalDelegation")
     |> quantity_to_integer_if_exist("amount")}
  end

  defp entry_to_elixir({key, value}) when key in ~w(from) do
    if String.starts_with?(value, "one1") do
      {key, decode_bech_32(value)}
    else
      {key, value}
    end
  end

  defp entry_to_elixir({key, quantity})
       when key in ~w(gas gasPrice nonce r s v) and
              quantity != nil do
    {key, quantity_to_integer(quantity)}
  end

  defp entry_to_elixir({key, timestamp})
       when key in ~w(timestamp) and
              timestamp != nil do
    {key, timestamp_to_datetime(timestamp)}
  end

  # as always ganache has it's own vision on JSON RPC standard
  defp entry_to_elixir({key, nil}) when key in ~w(r s v) do
    {key, 0}
  end

  defp entry_to_elixir({key, quantity_or_nil}) when key in ~w(blockNumber transactionIndex) do
    elixir =
      case quantity_or_nil do
        nil -> nil
        quantity -> quantity_to_integer(quantity)
      end

    {key, elixir}
  end

  defp entry_to_elixir(_) do
    {nil, nil}
  end

  defp quantity_to_integer_if_exist(transaction, key) do
    quantity = Map.get(transaction, key)

    if quantity do
      Map.put(transaction, key, quantity_to_integer(quantity))
    else
      transaction
    end
  end

  defp put_if_present(transaction, result, keys) do
    Enum.reduce(keys, result, fn {from_key, to_key}, acc ->
      value = transaction[from_key]

      if value do
        Map.put(acc, to_key, value)
      else
        acc
      end
    end)
  end
end
