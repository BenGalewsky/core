defmodule Core.Repo.Migrations.CreateSurveyResponse do
  use Ecto.Migration

  def change do
    create table(:survey_responses) do
      add :response, :string
      add :supporter_status, :string
      add :conversation_id, :integer
      add :conversation_status, :string
      add :first_name, :string
      add :last_name, :string
      add :num_messages, :integer
      add :opted_out, :string
      add :phone, :string
      add :texter_email, :string
      add :texter_first_name, :string
      add :texter_last_name, :string
      add :campaign_id, :integer

      timestamps()
    end

  end
end
