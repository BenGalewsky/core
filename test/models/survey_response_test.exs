defmodule Core.SurveyResponseTest do
  use Core.ModelCase

  alias Core.SurveyResponse

  @valid_attrs %{campaign_id: 42, conversation_id: 42, conversation_status: "some content", first_name: "some content", last_name: "some content", num_messages: 42, opted_out: "some content", phone: "some content", response: "some content", supporter_status: "some content", texter_email: "some content", texter_first_name: "some content", texter_last_name: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = SurveyResponse.changeset(%SurveyResponse{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = SurveyResponse.changeset(%SurveyResponse{}, @invalid_attrs)
    refute changeset.valid?
  end
end
