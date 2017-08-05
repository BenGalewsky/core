defmodule Core.Repo.Migrations.CreateRelayJob do
  use Ecto.Migration

  def change do
    create table(:relay_jobs) do
      add :start_time, :datetime

      timestamps()
    end

  end
end
