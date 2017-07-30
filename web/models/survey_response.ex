defmodule Core.SurveyResponse do
  use Core.Web, :model

  schema "survey_responses" do
    field :conversation_id, :integer
    field :conversation_status, :string
    field :first_name, :string
    field :last_name, :string
    field :num_messages, :integer
    field :opted_out, :string
    field :phone, :string
    field :responses, :map
    field :texter_email, :string
    field :texter_first_name, :string
    field :texter_last_name, :string
    field :campaign_id, :integer

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:conversation_id, :conversation_status, :first_name, :last_name, :num_messages, :opted_out, :phone, :responses, :texter_email, :texter_first_name, :texter_last_name, :campaign_id])
    |> validate_required([:conversation_id, :conversation_status, :first_name, :last_name, :num_messages, :opted_out, :phone, :texter_email, :texter_first_name, :texter_last_name])
    |> unique_constraint(:conversation_id)

  end

  def split_survey_responses(survey) do
  IO.puts("splittttz")
    Map.split(survey, ["conversation_id", "conversation_status", "first_name", "last_name", "num_messages", "opted_out", "phone", "responses", "texter_email", "texter_first_name", "texter_last_name", "campaign_id"])
  end
end
