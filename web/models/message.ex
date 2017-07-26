defmodule Core.Message do
  use Core.Web, :model

  schema "messages" do
    field :contact_first_name, :string
    field :contact_last_name, :string
    field :contact_phone, :string
    field :conversation_id, :integer
    field :message_body, :string
    field :message_direction, :string
    field :message_id, :integer
    field :sender_first_name, :string
    field :sender_last_name, :string
    field :sender_phone, :string
    field :timestamp, :string

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:contact_first_name, :contact_last_name, :contact_phone, :conversation_id, :message_body, :message_direction, :message_id, :sender_first_name, :sender_last_name, :sender_phone, :timestamp])
    |> validate_required([:contact_first_name, :contact_last_name, :contact_phone, :conversation_id, :message_body, :message_direction, :message_id, :sender_first_name, :sender_last_name, :sender_phone, :timestamp])
    |> unique_constraint(:message_id)
  end
end
