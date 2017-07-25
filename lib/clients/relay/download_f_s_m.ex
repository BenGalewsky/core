defmodule Relay.DownloadFSM do
  use Fsm, initial_state: :ready, initial_data: nil
  import Crontab.CronExpression
  import Timex
  import Core.SurveyResponse
  import Ecto.Query, only: [from: 2]


  @moduledoc false

  defstate ready do
    defevent start(fsm_data), data: campaign do
      %{:campaign => a_campaign, :export_type => export_type} = fsm_data
      IO.puts("Ready to download campaiogn " <> a_campaign.name)
      body_map = %{:data => %{:attributes => %{:export_type => export_type}}}
      body = Poison.encode!(body_map)
      #        request = Relay.Api.post("campaigns/#{a_campaign.campaign_id}/exports",
      #                        [body: body,
      #                         headers: ["Content-Type": "application/vnd.api+json"],
      #                         ibrowse: [ssl_options: [server_name_indication: 'relaytxt.io']]])


      next_state(:waiting, fsm_data)
    end
  end

  defstate waiting do

    def decompose_campaign(campaign) do
                %{"attributes" => attributes} = campaign
                attributes
    end

    def filter_ready_surveys(campaign_attributes) do
      filter_ready_files(campaign_attributes, "surveys")
    end

    def filter_ready_messages(campaign_attributes) do
      filter_ready_files(campaign_attributes, "messages")
    end


    def filter_ready_files(campaign_attributes, export_type) do
        %{"status" => status,
          "export_type" => export_type,
          "inserted_at" => inserted_at } = campaign_attributes
          with {:ok, insert_at_time} <- Timex.parse(inserted_at, "{ISO:Extended:Z}") do
            export_type == export_type and status == "finished"
          end
    end

    def find_downloadable_file(campaign, export_type) do
        response = Relay.Api.get("campaigns/#{campaign.campaign_id}/exports",
                                 [ibrowse: [ssl_options: [server_name_indication: 'relaytxt.io']]])
        bar = Poison.Parser.parse!(response.body)

        filter_fun = case export_type do
          "surveys" -> &filter_ready_surveys/1
          "messages" -> &filter_ready_messages/1
        end

        with {:ok, data} <- Map.fetch(bar, "data") do
            foo = Enum.map(data, fn(campaign) -> decompose_campaign(campaign) end)
                  |> Enum.filter(filter_fun)
                  |> Enum.take(1)

            IO.inspect(foo)
            cond do
              length(foo) == 0 ->
                {:not_ready}

              length(foo) == 1 ->
                {:ok, List.first(foo)}

               true ->
                {:error}
            end
         end
    end

    def check_download_ready(campaign, export_type, x) do
      :timer.sleep(1000)
      case find_downloadable_file(campaign, export_type) do
        {:not_ready} ->
            if x > 0 do
              IO.puts("Try again")
              check_download_ready(campaign, export_type, x-1)
            end
        {:ok, export_rec} ->
            IO.puts("\nFound one!")
            IO.inspect(export_rec)
            {:ok, export_rec}

        _ ->
            IO.puts("Error... nevermind")
            {:error, "Timed out"}
      end

    end

      defevent wait_for, data: download_config do
        IO.puts("\n\nWait For... ")
        IO.inspect(download_config)

       %{:campaign => campaign, :export_type => export_type} = download_config
            IO.puts("....waiting on "<> campaign.campaign_link)
            case check_download_ready(campaign, export_type, 2) do
              {:ok, export_rec} -> next_state(:downloading, export_rec)
              {:error, msg} -> next_state(:ready, nil)
            end
      end

    end

    defstate downloading do

      def upsert_survey(survey) do
        with {:ok, survey_data} <- survey,
         {survey_fields, survey_responses} <- Core.SurveyResponse.split_survey_responses(survey_data),
         {:ok, conversation_id} <- Map.fetch(survey_fields, "conversation_id") do
            IO.puts("existing")
            IO.inspect(conversation_id)
            existing = Core.Repo.get_by(Core.SurveyResponse, conversation_id: conversation_id)

            changeset = case existing do
              nil -> IO.puts("---- NOOOOOL -----")
                     Core.SurveyResponse.changeset(%Core.SurveyResponse{}, Map.put(survey_data, "responses", survey_responses))

              _ -> IO.inspect(existing)
                   Core.SurveyResponse.changeset(existing, Map.put(survey_data, "responses", survey_responses))
            end

           changeset = Core.SurveyResponse.changeset(%Core.SurveyResponse{}, Map.put(survey_data, "responses", survey_responses))
           Core.Repo.insert_or_update(changeset)
        end
      end

      def upsert_messages(message) do
        with {:ok, message_data} <- message,
         {:ok, message_id} <- Map.fetch(message_data, "message_id") do
            IO.puts("Message " <> message_id)
            IO.inspect(message_data)

        end
      end

      defevent download_file, data: export_rec do
        IO.puts("Downloading file")
        IO.inspect(export_rec)
        with {:ok, url} <- Map.fetch(export_rec, "csv_url"),
             {:ok, export_type} <- Map.fetch(export_rec, "export_type"),
             %HTTPotion.Response{ body: body, status_code: 200 } <- HTTPotion.get(url, [timeout: 30_000]) do
                upsert_fun = case export_type do
                    "surveys" -> &upsert_survey/1
                    "messages" -> &upsert_messages/1
                end

                Stream.map(String.split(body, "\n"), &(&1))
                   |>CSV.decode(separator: ?,, headers: true)
                   |>Enum.take(2)
                   |>Enum.map(upsert_fun)

                next_state(:ready, nil)
        end
      end
    end
  end
