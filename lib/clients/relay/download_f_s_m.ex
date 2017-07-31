defmodule Relay.DownloadFSM do
  use Fsm, initial_state: :ready, initial_data: nil
  import Crontab.CronExpression
  import Timex
  import Core.SurveyResponse
  import Ecto.Query, only: [from: 2]
  alias Relay.Campaigns, as: Campaigns



  @moduledoc false

  @relay_api Application.get_env(:core, :relay_api)
  @max_retries 5


  defstate ready do
    defevent start(download_config), data: campaign do
      %{:campaign => a_campaign, :export_type => export_type} = download_config
      IO.puts("Ready to download campaiogn " <> a_campaign.name)
      response = @relay_api.initiate_export(a_campaign.campaign_id, export_type)

      case response.status_code do
        201 -> next_state(:waiting, download_config)
        _ -> IO.puts("Error initiating download #{response.status_code}")
             next_state(:download_failed,
                      %{:message=> "unable to initiate export",
                        :download_config=> download_config})
      end

    end
  end

  defstate waiting do

      defevent wait_for, data: download_config do
        IO.puts("\n\nWait For... ")
        IO.inspect(download_config)

       %{:campaign => campaign, :export_type => export_type} = download_config

        case Campaigns.check_download_ready(campaign, export_type, @max_retries) do
          {:ok, export_rec} -> next_state(:downloading, export_rec)
          {:error, msg} -> next_state(:download_failed,
                                        %{:message=> "Timeout waiting for file to appear for",
                                          :download_config=> download_config})
        end
      end
    end

    defstate downloading do
      def upsert_survey(survey) do
        with {:ok, survey_data} <- survey,
         {survey_fields, survey_responses} <- Core.SurveyResponse.split_survey_responses(survey_data),
         {:ok, conversation_id} <- Map.fetch(survey_fields, "conversation_id") do
            existing = Core.Repo.get_by(Core.SurveyResponse, conversation_id: conversation_id)

            changeset = case existing do
              nil -> Core.SurveyResponse.changeset(%Core.SurveyResponse{}, Map.put(survey_data, "responses", survey_responses))

              _ ->   Core.SurveyResponse.changeset(existing, Map.put(survey_data, "responses", survey_responses))
            end

           changeset = Core.SurveyResponse.changeset(%Core.SurveyResponse{}, Map.put(survey_data, "responses", survey_responses))
           Core.Repo.insert_or_update(changeset)
          else
          survey_data -> IO.puts("error in survey")
                         IO.inspect(survey_data)
        end
      end

      def insert_new_messages(message) do
        with {:ok, message_data} <- message,
         {:ok, message_id} <- Map.fetch(message_data, "message_id") do
            IO.puts("Message " <> message_id)
            existing = Core.Repo.get_by(Core.Message, message_id: message_id)

            unless existing  do
                Core.Repo.insert(Core.Message.changeset(%Core.Message{}, message_data))
            end
        end
      end

      defevent download_file, data: export_rec do
        IO.puts("Downloading file")

        with {:ok, url} <- Map.fetch(export_rec, "csv_url"),
             {:ok, export_type} <- Map.fetch(export_rec, "export_type"),
             %HTTPotion.Response{ body: body, status_code: 200 } <- @relay_api.download_csv_file(url) do
                upsert_fun = case export_type do
                    "surveys" -> &upsert_survey/1
                    "messages" -> &insert_new_messages/1
                end

                Stream.map(String.split(body, "\n"), &(&1))
                   |>CSV.decode(separator: ?,, headers: true)
                   |>Enum.map(upsert_fun)

                next_state(:download_complete, export_rec)
        end
      end
    end

    defstate download_complete do

    end

    defstate download_failed do

    end
  end
