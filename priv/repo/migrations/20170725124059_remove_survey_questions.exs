defmodule Core.Repo.Migrations.RemoveSurveyQuestions do
  use Ecto.Migration

  def change do
    alter table(:survey_responses) do
      remove :response
      remove :supporter_status
    end

  end
end
