defmodule Core.Repo.Migrations.MakeConversationIdUnique do
  use Ecto.Migration

  def change do
        create unique_index(:survey_responses, [:conversation_id])
  end
end