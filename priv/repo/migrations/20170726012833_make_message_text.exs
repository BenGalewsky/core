defmodule Core.Repo.Migrations.MakeMessageText do
  use Ecto.Migration

  def change do
  alter table(:messages) do
    modify :message_body, :text
  end
  end
end
