defmodule Core.CampaignTest do
  use Core.ModelCase

  alias Core.Campaign

  @valid_attrs %{apportionment_failed_reason: "some content", campaign_id: "some content", campaign_link: "some content", close_time: "some content", conversations_count: "some content", description: "some content", end_date: %{day: 17, month: 4, year: 2010}, extra_info: "some content", initial_sent_count: "some content", name: "some content", open_time: "some content", opt_outs_count: "some content", replies_count: "some content", senders_count: "some content", start_date: %{day: 17, month: 4, year: 2010}, status: "some content", time_zone: "some content", type: "some content", unassigned_count: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Campaign.changeset(%Campaign{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Campaign.changeset(%Campaign{}, @invalid_attrs)
    refute changeset.valid?
  end
end
