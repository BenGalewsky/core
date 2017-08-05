defmodule Core.RelayJob do
  use Core.Web, :model

  schema "relay_jobs" do
    field :start_time, Timex.Ecto.DateTime
    has_many :tasks, Core.RelayTask
    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:start_time])
    |> validate_required([:start_time])
  end
end
