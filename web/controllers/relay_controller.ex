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
    foo = Relay.Api.get("campaigns",  [ ibrowse: [ssl_options: [server_name_indication: 'relaytxt.io']]])
    bar = Poison.Parser.parse!(foo.body)
    with {:ok, data} <- Map.fetch(bar, "data") do
        for campaign <- data do
            %{"id" => campaign_id, "attributes" => attributes, "links" => links} = campaign
            %{"description" => description,
                "start_date" => start_date,
                "name" => name,
                "end_date" => end_date,
                 "status" => status} = attributes
            %{"self" => campaign_link} = links
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
#                    {:ok, pid} = Relay.DownloadServer.start_link()
#                    Relay.DownloadServer.start(pid, %{:campaign => campaign, :export_type => "surveys"})

                    {:ok, pid_msgs} = Relay.DownloadServer.start_link()
                    Relay.DownloadServer.start(pid_msgs, %{:campaign => campaign, :export_type => "messages"})


                 end
              _ ->
                IO.inspect(cs)
            end



        end
    end


    render( conn, "index.html", brand: "bnc", mobile: false)
  end
end