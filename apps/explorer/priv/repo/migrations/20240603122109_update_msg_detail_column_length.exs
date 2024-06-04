defmodule Explorer.Repo.Migrations.UpdateMsgDetailsColumnLength do
  use Ecto.Migration

  def up do
    alter table("staking_transactions") do # Replace "your_table_name" with the actual table name
      modify(:msg_details, :text) # Change the type to :text to allow unlimited length
    end
  end

  def down do
    alter table("staking_transactions") do # Again, replace "your_table_name"
      modify(:msg_details, :string) # Revert to the original type and length
    end
  end
end
