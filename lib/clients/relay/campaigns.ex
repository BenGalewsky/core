defmodule Relay.Campaigns do
  @moduledoc false

    @relay_api Application.get_env(:core, :relay_api)

    @stale_export_mins 5


    defp decompose_campaign(campaign) do
                %{"attributes" => attributes} = campaign
                attributes
    end

    def filter_ready_surveys(campaign_attributes) do
      filter_ready_files(campaign_attributes, "surveys")
    end

    def filter_ready_messages(campaign_attributes) do
      filter_ready_files(campaign_attributes, "messages")
    end


    def filter_ready_files(campaign_attributes, a_export_type) do
        %{"status" => status,
          "export_type" => export_type,
          "inserted_at" => inserted_at } = campaign_attributes

          with {:ok, insert_at_time} <- Timex.parse(inserted_at, "{ISO:Extended:Z}") do
              age_in_mins = NaiveDateTime.diff(
                                          DateTime.to_naive(Timex.now),
                                          DateTime.to_naive(insert_at_time),
                                          :second) / 60

            export_type == a_export_type and status == "finished" and age_in_mins < @stale_export_mins
          else
            _ -> IO.puts("Invalid timestamp. #{inserted_at}... Skipping")
            false
          end

    end

    def find_downloadable_file(campaign, export_type) do
        filter_fun  = case export_type do
          "surveys" -> &filter_ready_surveys/1
          "messages" -> &filter_ready_messages/1
         end

        response = @relay_api.list_exports(campaign.campaign_id)

        with {:ok, body} <- Poison.Parser.parse(response.body),
         {:ok, data} <- Map.fetch(body, "data") do
            filtered = Enum.map(data, fn(campaign) -> decompose_campaign(campaign) end)
                  |> Enum.filter(filter_fun)
                  |> Enum.take(1)

            if length(filtered) == 1 do
                {:ok, List.first(filtered)}
             else
              IO.puts("not ready")
                {:not_ready}
            end
         end
    end

    def check_download_ready(campaign, export_type, x) do
      :timer.sleep(2000)

      case find_downloadable_file(campaign, export_type) do
        {:not_ready} ->
            if x > 0 do
              IO.puts("Try again")
              check_download_ready(campaign, export_type, x-1)
            else
                {:error, "Timed out"}
            end

        {:ok, export_rec} ->
            {:ok, export_rec}

        _ ->
            IO.puts("Error... nevermind")
            {:error}
      end

    end

    def stream_csv_file(body, upsert_fun) do
          foo = Stream.map(String.split(body, "\n"), &(&1))
             |>Enum.filter(fn(message) -> String.length(message) > 0 end)
             |>CSV.decode(separator: ?,, headers: true)
             |>Enum.map(upsert_fun)

           IO.puts("at end")
           IO.inspect(foo)
    end
  
end