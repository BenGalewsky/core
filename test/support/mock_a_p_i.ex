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
""", headers: [Connection: "keep-alive"], status_code: 404}
  end
  
end