defmodule Core.Repo.Migrations.EnhanceRelayTask do
  use Ecto.Migration

  def change do
    alter table(:relay_tasks) do
      add :campaign_id, :bigint
      add :message, :text
      remove :pid
     end
  end
end
