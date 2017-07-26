defmodule Core.Repo.Migrations.CreateMessage do
  use Ecto.Migration

  def change do
    create table(:messages) do
      add :contact_first_name, :string
      add :contact_last_name, :string
      add :contact_phone, :string
      add :conversation_id, :integer
      add :message_body, :string
      add :message_direction, :string
      add :message_id, :integer
      add :sender_first_name, :string
      add :sender_last_name, :string
      add :sender_phone, :string
      add :timestamp, :string

      timestamps()
    end
    create unique_index(:messages, [:message_id])

  end
end
