defmodule Core.Repo.Migrations.CreateCampaign do
  use Ecto.Migration

  def change do
    create table(:campaigns) do
      add :campaign_id, :string
      add :apportionment_failed_reason, :string
      add :close_time, :string
      add :conversations_count, :string
      add :description, :string
      add :end_date, :date
      add :extra_info, :string
      add :initial_sent_count, :string
      add :name, :string
      add :open_time, :string
      add :opt_outs_count, :string
      add :replies_count, :string
      add :senders_count, :string
      add :start_date, :date
      add :status, :string
      add :time_zone, :string
      add :unassigned_count, :string
      add :campaign_link, :string
      add :type, :string

      timestamps()
    end

  end
end
