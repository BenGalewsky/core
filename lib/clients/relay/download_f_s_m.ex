defmodule Relay.DownloadFSM do
  use Fsm, initial_state: :ready, initial_data: nil
  import Crontab.CronExpression
  import Timex


  @moduledoc false

  defstate ready do
    defevent start(a_campaign), data: campaign do
      IO.puts("Ready to download campaiogn " <> a_campaign.name)
      body_map = %{:data => %{:attributes => %{:export_type => "surveys"}}}
      body = Poison.encode!(body_map)
      #        request = Relay.Api.post("campaigns/#{a_campaign.campaign_id}/exports",
      #                        [body: body,
      #                         headers: ["Content-Type": "application/vnd.api+json"],
      #                         ibrowse: [ssl_options: [server_name_indication: 'relaytxt.io']]])


      next_state(:waiting, a_campaign)
    end
  end

  defstate waiting do

    def decompose_campaign(campaign) do
                %{"attributes" => attributes} = campaign
                attributes
    end

    def filter_ready_files(campaign_attributes) do
        %{"status" => status,
          "export_type" => export_type,
          "inserted_at" => inserted_at } = campaign_attributes
          with {:ok, insert_at_time} <- Timex.parse(inserted_at, "{ISO:Extended:Z}") do
            export_type == "surveys" and status == "finished"
          end
    end

    def find_downloadable_file(campaign) do
        response = Relay.Api.get("campaigns/#{campaign.campaign_id}/exports",
                                 [ibrowse: [ssl_options: [server_name_indication: 'relaytxt.io']]])
        bar = Poison.Parser.parse!(response.body)
        with {:ok, data} <- Map.fetch(bar, "data") do
            foo = Enum.map(data, fn(campaign) -> decompose_campaign(campaign) end)
                  |> Enum.filter(&filter_ready_files/1)
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

    def check_download_ready(campaign, x) do
      :timer.sleep(1000)
      case find_downloadable_file(campaign) do
        {:not_ready} ->
            if x > 0 do
              IO.puts("Try again")
              check_download_ready(campaign, x-1)
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

      defevent wait_for, data: campaign do
        IO.puts("....waiting on "<> campaign.campaign_link)
        case check_download_ready(campaign, 2) do
          {:ok, export_rec} -> next_state(:downloading, export_rec)
          {:error, msg} -> next_state(:ready, nil)
        end
      end

    end

    defstate downloading do
      defevent download_file, data: export_rec do
        IO.puts("Downloading file")
        IO.inspect(export_rec)
        with {:ok, url} <- Map.fetch(export_rec, "csv_url"),
             %HTTPotion.Response{ body: body, status_code: 200 } <- HTTPotion.get(url, [timeout: 30_000]) do
                foo = Stream.map(String.split(body, "\n"), &(&1))
                   |>CSV.decode(separator: ?,, headers: true)
                   |>Enum.take(2)
                IO.inspect(foo)

                file_data = %{:export_rec => export_rec, :file_path => foo}
                next_state(:importing, file_data)
        end
      end
    end

    defstate importing do
      defevent import_file, data: file_data do
        IO.puts("File Downloaded... now lets import")
        IO.inspect(file_data)


      end
    end


  end
