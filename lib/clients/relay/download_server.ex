defmodule Relay.DownloadServer do

    def download_campaign(download_config) do
        try do
          Relay.DownloadFSM.new
          |> Relay.DownloadFSM.start(download_config)
          |> Relay.DownloadFSM.wait_for()
          |> Relay.DownloadFSM.download_file
         rescue
           FunctionClauseError -> IO.puts("Can't continue'")
           {:error, "Can't continue"}
         end

    end
end