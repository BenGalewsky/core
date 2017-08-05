defmodule Core.RelayController do
  @moduledoc false
  use Core.Web, :controller
  require Logger
  import Relay.Api

  def index(conn, _params) do
    render( conn, "index.html", brand: "bnc", mobile: false)
  end


  def update(conn, _params) do
    ## Log this job run
    job_changeset = Core.RelayJob.changeset(%Core.RelayJob{}, %{:start_time=> Timex.now})
    {:ok, job} = Core.Repo.insert(job_changeset)

    IO.inspect(job)

    response = Relay.Api.list_campaigns()

      case response.status_code do
        200 ->
            with {:ok, relay_result} <-  Poison.Parser.parse(response.body),
                 {:ok, data} <- Map.fetch(relay_result, "data") do

                   #### Loop over each campaign in the result
                   task_list = for campaign <- data do
                        %{"id" => campaign_id,
                            "attributes" => %{"description" => description,
                                               "start_date" => start_date,
                                               "name" => name,
                                               "end_date" => end_date,
                                                "status" => status},
                                                "links" => %{"self" => campaign_link}} = campaign

                        IO.puts("--> "<>campaign_id<>"::"<>description <> ": " <> status)

                        ## Add the campaign record if this is the first time we've seen it
                        existing_campaign = Core.Repo.get_by(Core.Campaign, campaign_id: campaign_id)

                        campaign_struct = if (existing_campaign == nil), do: %Core.Campaign{}, else: existing_campaign
                        cs = Core.Campaign.changeset(campaign_struct,%{campaign_id: campaign_id,
                                                description: description,
                                                name: name,
                                                start_date: start_date,
                                                end_date: end_date,
                                                campaign_link: campaign_link,
                                                status: status})

                        case campaign_id do
                          "878455502" ->
                            with {:ok, campaign} <- Core.Repo.insert_or_update(cs) do
                                msgs_task = Task.Supervisor.async(CampaignSupervisor,
                                                             Relay.DownloadServer,
                                                             :download_campaign,
                                                             [%{:campaign => campaign,
                                                                :export_type => "messages",
                                                                :job=>job}])

                                surveys_task = Task.Supervisor.async(CampaignSupervisor,
                                                             Relay.DownloadServer,
                                                             :download_campaign,
                                                             [%{:campaign => campaign,
                                                                :export_type => "surveys",
                                                                :job=> job}])

                                [msgs_task, surveys_task]
                             end
                          _ -> []
                        end
                        end

                        filtered_task_list = Enum.filter(task_list, fn(x) -> length(x) > 0 end)
                        |>Enum.flat_map(&(&1))
                    end
         _ -> IO.puts("Erorr response #{response.status_code}")
        end


    render( conn, "index.html", brand: "bnc", mobile: false)
  end

  defp create_task(export_type) do
    task = Task.Supervisor.async(CampaignSupervisor, Relay.DownloadServer,
                                 :download_campaign, [%{:campaign => campaign, :export_type => export_type}])



  end
end