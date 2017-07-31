defmodule Core.RelayController do
  @moduledoc false
  use Core.Web, :controller
  require Logger
  import Relay.Api

  def index(conn, _params) do
    render( conn, "index.html", brand: "bnc", mobile: false)
  end


  def update(conn, _params) do
    Logger.info("Hi there.. Time to update")
      response = Relay.Api.list_campaigns()

      case response.status_code do
        200 ->
            with {:ok, relay_result} <-  Poison.Parser.parse(response.body),
                 {:ok, data} <- Map.fetch(relay_result, "data") do

                   #### Loop over each campaign in the result
                    for campaign <- data do
                        %{"id" => campaign_id,
                            "attributes" => %{"description" => description,
                                               "start_date" => start_date,
                                               "name" => name,
                                               "end_date" => end_date,
                                                "status" => status},
                                                "links" => %{"self" => campaign_link}} = campaign

                        IO.puts("--> "<>campaign_id<>"::"<>description <> ": " <> status)
                        cs = Core.Campaign.changeset(%Core.Campaign{},%{campaign_id: campaign_id,
                                                description: description,
                                                name: name,
                                                start_date: start_date,
                                                end_date: end_date,
                                                campaign_link: campaign_link,
                                                status: status})
                        case campaign_id do
                          "1218017917" ->
                            with {:ok, campaign} <- Core.Repo.insert(cs) do
                                msgs_task = Task.Supervisor.async(CampaignSupervisor,
                                                             Relay.DownloadServer,
                                                             :download_campaign,
                                                             [%{:campaign => campaign, :export_type => "messages"}])

                                surveys_task = Task.Supervisor.async(CampaignSupervisor,
                                                             Relay.DownloadServer,
                                                             :download_campaign,
                                                             [%{:campaign => campaign, :export_type => "surveys"}])

                             end
                          _ ->
    #                        IO.inspect(cs)
                        end
                        end
                    end
         _ -> IO.puts("Erorr response #{response.status_code}")
        end

    render( conn, "index.html", brand: "bnc", mobile: false)
  end
end