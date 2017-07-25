defmodule Core.Repo.Migrations.AddSurveyJson do
  use Ecto.Migration

  def change do
    alter table(:survey_responses) do
      add :responses, :map
    end
  end
end
