defmodule Core.Campaign do
  use Core.Web, :model

  schema "campaigns" do
    field :campaign_id, :string
    field :apportionment_failed_reason, :string
    field :close_time, :string
    field :conversations_count, :string
    field :description, :string
    field :end_date, Timex.Ecto.DateTime
    field :extra_info, :string
    field :initial_sent_count, :string
    field :name, :string
    field :open_time, :string
    field :opt_outs_count, :string
    field :replies_count, :string
    field :senders_count, :string
    field :start_date, Timex.Ecto.DateTime
    field :status, :string
    field :time_zone, :string
    field :unassigned_count, :string
    field :campaign_link, :string
    field :type, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:campaign_id, :apportionment_failed_reason, :close_time, :conversations_count, :description, :end_date, :extra_info, :initial_sent_count, :name, :open_time, :opt_outs_count, :replies_count, :senders_count, :start_date, :status, :time_zone, :unassigned_count, :campaign_link, :type])
    |> validate_required([:campaign_id,  :name, :status, :campaign_link])
  end
end
