defmodule Explorer.Repo.Migrations.AddEthHashIndex do
  use Ecto.Migration

  def change do
    create index(:transactions, [:eth_hash])
  end
end
