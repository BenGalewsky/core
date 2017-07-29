defmodule Relay.MockAPI do
  @moduledoc false

  def initiate_export(1234, "surveys") do
    %HTTPotion.Response{body: "...", headers: [Connection: "keep-alive"], status_code: 201}
  end

  def initiate_export(-1, "surveys") do
    %HTTPotion.Response{body: "...", headers: [Connection: "keep-alive"], status_code: 404}
  end

  def list_exports(1234) do
    %HTTPotion.Response{body: """
{
"jsonapi": {
"version": "1.0"
},
"data": [
  {
        "type": "export",
        "id": "3018595101",
        "attributes": {
        "status": "finished",
        "start_date": null,
        "inserted_at": "2017-07-25T20:34:01.03303Z",
        "export_type": "messages",
        "end_date": null,
        "csv_url": "https://s3.amazonaws.com/foo",
        "campaign_id": 343107058
    }
}
]
}
""", status_code: 200}
  end


  def list_exports("no_exports") do
    %HTTPotion.Response{body: """
{
"jsonapi": {
"version": "1.0"
},
"data": [
]
}
""", status_code: 200}
  end

  def list_exports("export_processing") do
    %HTTPotion.Response{
        body: generate_json_body([generate_export_entry(%{"status"=> "processing"})]),
        status_code: 200}
  end

    def list_exports("message_export_ready") do
      %HTTPotion.Response{
          body: generate_json_body([generate_export_entry(%{"export_type"=> "messages"})]),
          status_code: 200}
    end

    def list_exports("Survey_within_five_minutes") do
        now = Timex.now

    with {:ok, export_time_str} <- Timex.shift(now, minutes: -4)
                                 |> Timex.format("{ISO:Extended:Z}") do
            %HTTPotion.Response{
                      body: generate_json_body([generate_export_entry(%{"inserted_at"=> export_time_str})]),
                      status_code: 200}

        end
    end

    def list_exports("Survey_more_than_five_minutes") do
        now = Timex.now

    with {:ok, export_time_str} <- Timex.shift(now, minutes: -5)
                                 |> Timex.format("{ISO:Extended:Z}") do
            %HTTPotion.Response{
                      body: generate_json_body([generate_export_entry(%{"inserted_at"=> export_time_str})]),
                      status_code: 200}

        end
    end

    defp generate_json_body(data)  do
        Poison.encode!(%{
          "jsonapi" => %{
          "version"=> "1.0"
          },
          "data" => data
          })
    end

    defp generate_export_entry() do
         generate_export_entry(%{})
    end

    defp generate_export_entry(custom_attributes) do
      attr = Map.merge( %{
                 "status"=> "finished",
                 "start_date"=> nil,
                 "inserted_at"=> "2017-07-25T20:34:01.03303Z",
                 "export_type"=> "messages",
                 "end_date"=> nil,
                 "csv_url"=> "https=>//s3.amazonaws.com/foo",
                 "campaign_id"=> 343107058
               }, custom_attributes)

      %{    "type"=> "export",
            "id"=> "3018595101",
            "attributes"=> attr
        }
    end
  
end