defmodule Core.RelayTask do
  use Core.Web, :model

  schema "relay_tasks" do
    field :start_time, Timex.Ecto.DateTime
    field :end_time, Timex.Ecto.DateTime
    field :status, :string
    field :campaign_id, :integer
    field :message, :string
    belongs_to :job, Core.RelayJob

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:start_time, :end_time, :status, :campaign_id, :message])
    |> validate_required([:status, :campaign_id])
  end
end
