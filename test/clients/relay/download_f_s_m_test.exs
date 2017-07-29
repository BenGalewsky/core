defmodule Core.DownloadFSMTest do
use ExUnit.Case


    test "given a ready FSM when I start with valid campaign" do
      new_state = Relay.DownloadFSM.new
      |> Relay.DownloadFSM.start(%{:campaign=> %{:name=>"test campaign", :campaign_id=>1234}, :export_type=>"surveys"})

      assert new_state.state == :waiting
      assert new_state.data.export_type == "surveys"
    end

    test "given a ready FSM when I start with invalid campaign" do
      new_state = Relay.DownloadFSM.new
      |> Relay.DownloadFSM.start(%{:campaign=> %{:name=>"bad campaign", :campaign_id=> -1}, :export_type=>"surveys"})

      assert new_state.state == :ready
    end

    test "given an FSM waiting for an export when file appears" do
        new_state = fsm_in_waiting
                    |> Relay.DownloadFSM.wait_for()

        IO.inspect(new_state)

    end


    defp fsm_in_waiting() do
            Relay.DownloadFSM.new
            |> Relay.DownloadFSM.start(%{:campaign=> %{:name=>"test campaign", :campaign_id=>1234}, :export_type=>"surveys"})
    end

end