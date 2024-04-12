defmodule Explorer.Chain.StakingTransaction.Type do
  @moduledoc """
  This module is responsible for defining the staking transaction types.
  """

  use Ecto.Type

  @typedoc """
  The staking transaction type.
  * `CreateValidator` - The transaction to create a validator.
  * `EditValidator` - The transaction to edit a validator.
  * `CollectRewards` - The transaction to collect rewards.
  * `Undelegate` - The transaction to undelegate.
  * `Delegate` - The transaction to delegate.
  """
  @type t :: :create_validator | :edit_validator | :collect_rewards | :undelegate | :delegate

  @doc """
  Casts `term` to `t:t/0`

  If the `term` is already in `t:t/0`, then it is returned

      iex> Explorer.Chain.StakingTransaction.Type.cast(:create_validator)
      {:ok, :create_validator}
      iex> Explorer.Chain.StakingTransaction.Type.cast(:edit_validator)
      {:ok, :edit_validator}
      iex> Explorer.Chain.StakingTransaction.Type.cast(:collect_rewards)
      {:ok, :collect_rewards}
      iex> Explorer.Chain.StakingTransaction.Type.cast(:undelegate)
      {:ok, :undelegate}
      iex> Explorer.Chain.StakingTransaction.Type.cast(:delegate)
      {:ok, :delegate}

  If the `term` is an `non_neg_integer`, then it is converted only if it is `0` or `1` or `2` or `3` or `4`.

      iex> Explorer.Chain.StakingTransaction.Type.cast(0)
      {:ok, :create_validator}
      iex> Explorer.Chain.StakingTransaction.Type.cast(1)
      {:ok, :edit_validator}
      iex> Explorer.Chain.StakingTransaction.Type.cast(2)
      {:ok, :collect_rewards}
      iex> Explorer.Chain.StakingTransaction.Type.cast(3)
      {:ok, :undelegate}
      iex> Explorer.Chain.StakingTransaction.Type.cast(4)
      :error

  If the `term` is in the quantity format used by `Explorer.JSONRPC`, it is converted only if `CreateValidator` or `EditValidator` or `CollectRewards` or `Undelegate` or `Delegate`

      iex> Explorer.Chain.StakingTransaction.Type.cast("CreateValidator")
      {:ok, :create_validator}
      iex> Explorer.Chain.StakingTransaction.Type.cast("EditValidator")
      {:ok, :edit_validator}
      iex> Explorer.Chain.StakingTransaction.Type.cast("CollectRewards")
      {:ok, :collect_rewards}
      iex> Explorer.Chain.StakingTransaction.Type.cast("Undelegate")
      {:ok, :undelegate}
      iex> Explorer.Chain.StakingTransaction.Type.cast("Delegate")
      {:ok, :delegate}
      iex> Explorer.Chain.StakingTransaction.Type.cast("Invalid")
      :error
  """
  @impl Ecto.Type
  @spec cast(term()) :: {:ok, t()} | :error
  def cast(:create_validator), do: {:ok, :create_validator}
  def cast(:edit_validator), do: {:ok, :edit_validator}
  def cast(:collect_rewards), do: {:ok, :collect_rewards}
  def cast(:undelegate), do: {:ok, :undelegate}
  def cast(:delegate), do: {:ok, :delegate}
  def cast(0), do: {:ok, :create_validator}
  def cast(1), do: {:ok, :edit_validator}
  def cast(2), do: {:ok, :collect_rewards}
  def cast(3), do: {:ok, :undelegate}
  def cast(4), do: {:ok, :delegate}
  def cast("CreateValidator"), do: {:ok, :create_validator}
  def cast("EditValidator"), do: {:ok, :edit_validator}
  def cast("CollectRewards"), do: {:ok, :collect_rewards}
  def cast("Undelegate"), do: {:ok, :undelegate}
  def cast("Delegate"), do: {:ok, :delegate}
  def cast(_), do: :error

  @doc """
  Dumps the `atom` format to `integer` format used in database.

      iex> Explorer.Chain.StakingTransaction.Type.dump(:create_validator)
      {:ok, 0}
      iex> Explorer.Chain.StakingTransaction.Type.dump(:edit_validator)
      {:ok, 1}
      iex> Explorer.Chain.StakingTransaction.Type.dump(:collect_rewards)
      {:ok, 2}
      iex> Explorer.Chain.StakingTransaction.Type.dump(:undelegate)
      {:ok, 3}
      iex> Explorer.Chain.StakingTransaction.Type.dump(:delegate)
      {:ok, 4}

  If the value hasn't been cast first, it can't be dumped.

      iex> Explorer.Chain.StakingTransaction.Type.dump(0)
      :error
      iex> Explorer.Chain.StakingTransaction.Type.dump(1)
      :error
      iex> Explorer.Chain.StakingTransaction.Type.dump(2)
      :error
      iex> Explorer.Chain.StakingTransaction.Type.dump(3)
      :error
      iex> Explorer.Chain.StakingTransaction.Type.dump(4)
      :error
  """
  @impl Ecto.Type
  @spec dump(term()) :: {:ok, 0 | 1 | 2 | 3 | 4} | :error
  def dump(:create_validator), do: {:ok, 0}
  def dump(:edit_validator), do: {:ok, 1}
  def dump(:collect_rewards), do: {:ok, 2}
  def dump(:undelegate), do: {:ok, 3}
  def dump(:delegate), do: {:ok, 4}
  def dump(_), do: :error

  @doc """
  Loads the integer from the database.

  Only loads integers `0`, `1`, `2`, `3`, and `4`.

      iex> Explorer.Chain.StakingTransaction.Type.load(0)
      {:ok, :create_validator}
      iex> Explorer.Chain.StakingTransaction.Type.load(1)
      {:ok, :edit_validator}
      iex> Explorer.Chain.StakingTransaction.Type.load(2)
      {:ok, :collect_rewards}
      iex> Explorer.Chain.StakingTransaction.Type.load(3)
      {:ok, :undelegate}
      iex> Explorer.Chain.StakingTransaction.Type.load(4)
      {:ok, :delegate}
      iex> Explorer.Chain.StakingTransaction.Type.load(5)
      :error

  """
  @impl Ecto.Type
  @spec load(term()) :: {:ok, t()} | :error
  def load(0), do: {:ok, :create_validator}
  def load(1), do: {:ok, :edit_validator}
  def load(2), do: {:ok, :collect_rewards}
  def load(3), do: {:ok, :undelegate}
  def load(4), do: {:ok, :delegate}
  def load(_), do: :error

  @doc """
  The underlying database type: `:integer`
  """
  @impl Ecto.Type
  @spec type() :: :integer
  def type, do: :integer
end
