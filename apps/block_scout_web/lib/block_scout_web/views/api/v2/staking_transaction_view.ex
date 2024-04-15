defmodule BlockScoutWeb.API.V2.StakingTransactionView do
  use BlockScoutWeb, :view

  alias BlockScoutWeb.API.V2.{ApiView, Helper}
  # alias Ecto.Association.NotLoaded
  # alias Explorer.{Chain, Market}
  # alias Explorer.Chain.{Address, Block, Hash, StakingTransaction, Wei}
  # alias Timex.Duration

  def render("staking_transaction.json", %{transaction: transaction, conn: conn}) do
    prepare_transaction(transaction)
  end

  def render("staking_transactions.json", %{transactions: transactions, next_page_params: next_page_params}) do
    %{
      "items" => Enum.map(transactions, &prepare_transaction/1),
      "next_page_params" => next_page_params
    }
  end

  def render("staking_transactions.json", %{transactions: transactions, conn: conn}) do
    Enum.map(transactions, &prepare_transaction/1)
  end

  defp prepare_transaction(transaction) do
    %{
      hash: transaction.hash,
      nonce: transaction.nonce,
      timestamp: transaction.timestamp,
      gas_price: transaction.gas_price,
      gas: transaction.gas,
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
end
