defmodule BlockScoutWeb.API.V2.StakingTransactionController do
  use BlockScoutWeb, :controller

  import Explorer.MicroserviceInterfaces.BENS, only: [maybe_preload_ens_to_transaction: 1]

  alias BlockScoutWeb.AccessHelper
  alias Explorer.{Chain}
  alias Explorer.Chain.{StakingTransaction}

  action_fallback(BlockScoutWeb.API.V2.FallbackController)

  @staking_transaction_necessity_by_association %{
    :block => :optional,
    [from_address: :names] => :optional
  }

  @api_true [api?: true]

  @spec staking_transaction(Plug.Conn.t(), map()) :: Plug.Conn.t() | {atom(), any()}
  def staking_transaction(conn, %{"staking_transactions_hash_param" => staking_transaction_hash_string} = params) do
    necessity_by_association = @staking_transaction_necessity_by_association

    with {:ok, transaction, _transaction_hash} <-
           validate_transaction(staking_transaction_hash_string, params,
             necessity_by_association: necessity_by_association,
             api?: true
           ) do
      conn
      |> put_status(200)
      |> render(:staking_transaction, %{transaction: transaction |> maybe_preload_ens_to_transaction()})
    end
  end

  @doc """
  Checks if this valid transaction hash string, and this transaction doesn't belong to prohibited address
  """
  @spec validate_transaction(String.t(), any(), Keyword.t()) ::
          {:format, :error}
          | {:not_found, {:error, :not_found}}
          | {:restricted_access, true}
          | {:ok, StakingTransaction.t(), Hash.t()}
  def validate_transaction(transaction_hash_string, params, options \\ @api_true) do
    with {:format, {:ok, transaction_hash}} <- {:format, Chain.string_to_transaction_hash(transaction_hash_string)},
         {:not_found, {:ok, transaction}} <-
           {:not_found, Chain.hash_to_staking_transaction(transaction_hash, options)},
         {:ok, false} <- AccessHelper.restricted_access?(to_string(transaction.from_address_hash), params) do
      {:ok, transaction, transaction_hash}
    end
  end
end
