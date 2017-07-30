defmodule Relay.Api do
    use HTTPotion.Base
  @moduledoc false

  @relay_account Application.get_env(:core, :relay_account)
  @relay_key Application.get_env(:core, :relay_key)

  defp process_url(url) do
    foo = "https://api.relaytxt.io/v1/accounts/#{@relay_account}/" <> url
    IO.inspect(foo)
    foo
  end

  defp process_request_headers(hdrs) do
    Enum.into(hdrs, ["Authorization": "Token token=#{@relay_key}"])
  end

  def list_campaigns do
    get("campaigns",  [ ibrowse: [ssl_options: [server_name_indication: 'relaytxt.io']]])
  end

  def list_exports(campaign_id) do
            get("campaigns/#{campaign_id}/exports",
                                     [ibrowse: [ssl_options: [server_name_indication: 'relaytxt.io']]])
  end


  def initiate_export(campaign_id, export_type) do
    body_map = %{:data => %{:attributes => %{:export_type => export_type}}}
    with{:ok, body} <- Poison.encode(body_map) do
        post("campaigns/#{campaign_id}/exports",
                [body: body,
                 headers: ["Content-Type": "application/vnd.api+json"],
                 ibrowse: [ssl_options: [server_name_indication: 'relaytxt.io']]])
     end

  end


  def download_csv_file(csv_url) do
    HTTPotion.get(csv_url, [timeout: 30_000])
  end

  
end