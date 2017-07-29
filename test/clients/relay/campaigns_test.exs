defmodule Relay.CampaignsTest do
  @moduledoc false
  use ExUnit.Case
  use Timex
  alias Relay.Campaigns, as: Campaigns

  test "given no exports exist for campaign" do
    result = Relay.Campaigns.find_downloadable_file(%{:campaign_id=>"no_exports"}, "surveys")
    assert elem(result,0) == :not_ready
  end

  test "given the export is still being generated" do
    result = Relay.Campaigns.find_downloadable_file(%{:campaign_id=>"export_processing"}, "surveys")
    assert elem(result,0) == :not_ready
  end

  test "given we are looking for surveys but only message exportsare available" do
    result = Relay.Campaigns.find_downloadable_file(%{:campaign_id=>"message_export_ready"}, "surveys")
    assert elem(result,0) == :not_ready
  end

  test "given an export was generated within 5 minutes of query" do
    result = Campaigns.find_downloadable_file(%{:campaign_id=>"Survey_within_five_minutes"}, "messages")
    assert elem(result,0) == :ok
  end

  test "given an export was generated more than 5 minutes of query" do
    result = Campaigns.find_downloadable_file(%{:campaign_id=>"Survey_more_than_five_minutes"}, "messages")
    assert elem(result,0) == :not_ready
  end

  test "given the export doesn't appear after max retries" do
    result = Campaigns.check_download_ready(%{:campaign_id=>"Survey_more_than_five_minutes"}, "messages", 1)
    assert elem(result,0) == :error
  end

end