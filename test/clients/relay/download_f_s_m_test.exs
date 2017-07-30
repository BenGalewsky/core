defmodule Core.DownloadFSMTest do
use ExUnit.Case

@tag :do
    test "given a ready FSM when I start with valid campaign" do
      new_state = Relay.DownloadFSM.new
      |> Relay.DownloadFSM.start(%{:campaign=> %{:name=>"test campaign", :campaign_id=>1234}, :export_type=>"surveys"})

      assert new_state.state == :waiting
      assert new_state.data.export_type == "surveys"
    end

@tag :do
    test "given a ready FSM when I start with invalid campaign" do
      new_state = Relay.DownloadFSM.new
      |> Relay.DownloadFSM.start(%{:campaign=> %{:name=>"bad campaign", :campaign_id=> -1}, :export_type=>"surveys"})

      assert new_state.state == :ready
    end

@tag :do
    test "given an FSM waiting for an export when file appears" do
        %Relay.DownloadFSM{data: data} = fsm_in_waiting()
                    |> Relay.DownloadFSM.wait_for()

        with {:ok, csv_url} <- Map.fetch(data, "csv_url") do
         assert(csv_url == "https=>//s3.amazonaws.com/foo")
        else
         _ -> flunk("no csv_url proivided")
        end

    end


@tag :skip
    # This test requires a db
    test "given a file to be downloaded" do
       %Relay.DownloadFSM{data: data} = fsm_in_waiting()
                    |> Relay.DownloadFSM.wait_for()
                    |> Relay.DownloadFSM.download_file()
        IO.inspect(data)
    end


    defp fsm_in_waiting() do
            Relay.DownloadFSM.new
            |> Relay.DownloadFSM.start(%{:campaign=> %{:name=>"test campaign", :campaign_id=>"Survey_within_five_minutes"}, :export_type=>"surveys"})
    end

end