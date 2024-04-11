defmodule EthereumJSONRPC.StakingTransactions do
  @moduledoc """
  List of staking transactions format as included in return from
  """

  alias EthereumJSONRPC.StakingTransaction

  @type elixir :: [StakingTransaction.elixir()]
  @type params :: [StakingTransaction.params()]
  @type t :: [StakingTransaction.t()]

  @doc """
  Converts each entry in `elixir` to params used in `Explorer.Chain.StakingTransaction.changeset/2`.
  """
  def elixir_to_params(elixir) when is_list(elixir) do
    Enum.map(elixir, &StakingTransaction.elixir_to_params/1)
  end

  @doc """
  Extract just the `t:Explorer.Chain.StakingTransaction.t/0` `hash` from `params` list elements.
  """
  def params_to_hashes(params) when is_list(params) do
    Enum.map(params, &StakingTransaction.params_to_hash/1)
  end

  @doc """
  Decodes stringly typed fields in entries in `staking_transactions`
  """
  def to_elixir(staking_transactions, block_timestamp \\ nil) when is_list(staking_transactions) do
    staking_transactions
    |> Enum.map(&StakingTransaction.to_elixir(&1, block_timestamp))
    |> Enum.filter(&(!is_nil(&1)))
  end
end
