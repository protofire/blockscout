defmodule Explorer.Chain.StakingTransaction do
  @moduledoc """
  This module is responsible for parsing the staking transaction data from the block.
  """

  use Explorer.Schema

  alias Explorer.{PagingOptions}

  alias Explorer.Chain.{
    Address,
    Block,
    Hash,
    Wei
  }

  alias Explorer.Chain.Transaction.{Status}

  alias Explorer.Chain.StakingTransaction.{
    Type
  }

  @required_attrs ~w(hash nonce timestamp gas_price gas v r s type)a

  @optional_attrs ~w(block_hash block_number gas_used cumulative_gas_used status transaction_index from_address_hash msg_validator_address msg_name msg_commission_rate msg_max_commission_rate msg_max_change_rate msg_min_self_delegation msg_max_total_delegation msg_amount msg_website msg_identity msg_security_contact msg_details msg_slot_pub_keys msg_delegator_address msg_slot_pub_key_to_add msg_slot_pub_key_to_remove)a

  @type transaction_index :: non_neg_integer()

  @typedoc """
  The staking transaction schema.

  * `hash` - The hash of the transaction.
  * `nonce` - The nonce of the transaction.
  * `block_hash` - The hash of the block where the transaction is included.
  * `block_number` - The block number where the transaction is included.
  * `transaction_index` - The index of the transaction in the block.
  * `timestamp` - The timestamp of the transaction.
  * `from_address_hash` - The hash of the address that sent the transaction.
  * `value` - The value of the transaction.
  * `gas_price` - The gas price of the transaction.
  * `v` - The v value of the transaction.
  * `r` - The r value of the transaction.
  * `s` - The s value of the transaction.
  * `type` - The type of the staking transaction.
  * `msg_validator_address` - The validator address.
  * `msg_name` - The name of the validator.
  * `msg_commission_rate` - The commission rate of the validator.
  * `msg_max_commission_rate` - The maximum commission rate of the validator.
  * `msg_max_change_rate` - The maximum change rate of the validator.
  * `msg_min_self_delegation` - The minimum self delegation of the validator.
  * `msg_max_total_delegation` - The maximum total delegation of the validator.
  * `msg_amount` - The amount of the transaction.
  * `msg_website` - The website of the validator.
  * `msg_identity` - The identity of the validator.
  * `msg_security_contact` - The security contact of the validator.
  * `msg_details` - The details of the validator.
  * `msg_slot_pub_keys` - The slot public keys of the validator.
  * `msg_delegator_address` - The delegator address.
  * `msg_slot_pub_key_to_add` - The slot public key to add.
  * `msg_slot_pub_key_to_remove` - The slot public key to remove.
  """
  @type t :: %__MODULE__{
          hash: Hash.t(),
          nonce: non_neg_integer(),
          block: %Ecto.Association.NotLoaded{} | Block.t() | nil,
          block_hash: Hash.t() | nil,
          block_number: Block.block_number() | nil,
          transaction_index: transaction_index | nil,
          timestamp: non_neg_integer(),
          from_address: %Ecto.Association.NotLoaded{} | Address.t(),
          from_address_hash: Hash.Address.t(),
          value: Wei.t() | nil,
          gas: Decimal.t(),
          gas_price: Wei.t(),
          cumulative_gas_used: Gas.t() | nil,
          gas_used: Gas.t() | nil,
          status: Status.t() | nil,
          v: Decimal.t(),
          r: Decimal.t(),
          s: Decimal.t(),
          type: Type.t(),
          msg_validator_address: String.t() | nil,
          msg_name: String.t() | nil,
          msg_commission_rate: Decimal.t() | nil,
          msg_max_commission_rate: Decimal.t() | nil,
          msg_max_change_rate: Decimal.t() | nil,
          msg_min_self_delegation: Decimal.t() | nil,
          msg_max_total_delegation: Decimal.t() | nil,
          msg_amount: Wei.t() | nil,
          msg_website: String.t() | nil,
          msg_identity: String.t() | nil,
          msg_security_contact: String.t() | nil,
          msg_details: String.t() | nil,
          msg_slot_pub_keys: [String.t()] | nil,
          msg_delegator_address: String.t() | nil,
          msg_slot_pub_key_to_add: String.t() | nil,
          msg_slot_pub_key_to_remove: String.t() | nil
        }

  @primary_key {:hash, Hash.Full, autogenerate: false}
  schema "staking_transactions" do
    field(:nonce, :integer)
    field(:block_number, :integer)
    field(:transaction_index, :integer)
    field(:timestamp, :integer)
    field(:value, Wei)
    field(:gas_price, Wei)
    field(:gas, :decimal)
    field(:cumulative_gas_used, :decimal)
    field(:gas_used, :decimal)
    field(:status, Status)
    field(:v, :decimal)
    field(:r, :decimal)
    field(:s, :decimal)
    field(:type, Type)
    field(:msg_validator_address, :string)
    field(:msg_name, :string)
    field(:msg_commission_rate, :decimal)
    field(:msg_max_commission_rate, :decimal)
    field(:msg_max_change_rate, :decimal)
    field(:msg_min_self_delegation, :decimal)
    field(:msg_max_total_delegation, :decimal)
    field(:msg_amount, Wei)
    field(:msg_website, :string)
    field(:msg_identity, :string)
    field(:msg_security_contact, :string)
    field(:msg_details, :string)
    field(:msg_slot_pub_keys, {:array, :string})
    field(:msg_delegator_address, :string)
    field(:msg_slot_pub_key_to_add, :string)
    field(:msg_slot_pub_key_to_remove, :string)

    timestamps()

    belongs_to(:block, Block, foreign_key: :block_hash, references: :hash, type: Hash.Full)
    belongs_to(:from_address, Address, foreign_key: :from_address_hash, references: :hash, type: Hash.Address)
  end

  def changeset(%__MODULE__{} = t, attrs \\ %{}) do
    t
    |> cast(attrs, @required_attrs ++ @optional_attrs)
    |> validate_required(@required_attrs)
    # |> foreign_key_constraint(:block_hash)
    |> unique_constraint(:hash)
  end

  @spec block_hash_to_staking_transactions_query(Hash.Full.t()) :: Ecto.Query.t()
  def block_hash_to_staking_transactions_query(block_hash) do
    block_hash
    |> block_hash_to_staking_transactions_unordered_query()
    |> order_by(desc: :timestamp)
  end

  @spec block_hash_to_staking_transactions_unordered_query(Hash.Full.t()) :: Ecto.Query.t()
  def block_hash_to_staking_transactions_unordered_query(block_hash) do
    from(staking_transaction in __MODULE__,
      select: staking_transaction,
      where: staking_transaction.block_hash == ^block_hash
    )
  end

  @spec address_hash_to_staking_transactions_query(Hash.Address.t()) :: Ecto.Query.t()
  def address_hash_to_staking_transactions_query(address_hash) do
    address_hash
    |> address_hash_to_staking_transactions_unordered_query()
    |> order_by(desc: :timestamp)
  end

  @spec address_hash_to_staking_transactions_unordered_query(Hash.Address.t()) :: Ecto.Query.t()
  def address_hash_to_staking_transactions_unordered_query(address_hash) do
    from(staking_transaction in __MODULE__,
      select: staking_transaction,
      where: staking_transaction.from_address_hash == ^address_hash
    )
  end

  @spec page_staking_transactions(Ecto.Query.t(), PagingOptions.t()) :: Ecto.Query.t()
  def page_staking_transactions(query, %PagingOptions{key: nil}), do: query

  def page_staking_transactions(query, %PagingOptions{key: {timestamp}}) do
    where(query, [staking_transaction], staking_transaction.timestamp < ^timestamp)
  end

  @doc """
  Returns next page params based on the provided transaction.
  """
  @spec next_page_params(Explorer.Chain.StakingTransaction.t()) :: %{
          required(String.t()) => Decimal.t() | Wei.t() | non_neg_integer | DateTime.t() | Hash.t()
        }
  def next_page_params(%__MODULE__{block_number: block_number, timestamp: timestamp, hash: hash}) do
    %{
      "block_number" => block_number,
      "timestamp" => timestamp,
      "hash" => hash
    }
  end
end
