defmodule Core.Repo.Migrations.MakeMessageIdBigint do
  use Ecto.Migration

  def change do
  alter table(:messages) do
    modify :message_id, :bigint
    modify :conversation_id, :bigint

  end

  end
end
