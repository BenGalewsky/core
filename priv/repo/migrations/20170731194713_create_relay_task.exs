defmodule Core.Repo.Migrations.CreateRelayTask do
  use Ecto.Migration

  def change do
    create table(:relay_tasks) do
      add :start_time, :datetime
      add :end_time, :datetime
      add :status, :string
      add :pid, :string
      add :job_id, references(:relay_jobs)

      timestamps()
    end

  end
end
