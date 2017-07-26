defmodule Relay.DownloadServer do
  use ExActor.GenServer


    defstart start_link(), do: initial_state(nil)

    defcast start(download_config) do
      Relay.DownloadFSM.new
      |> Relay.DownloadFSM.start(download_config)
      |> Relay.DownloadFSM.wait_for()
      |> Relay.DownloadFSM.download_file
      |> new_state
    end

      defcall state, state: fsm, do: reply(Relay.DownloadFSM.state(fsm))
      defcall data, state: fsm, do: reply(Relay.DownloadFSM.data(fsm))


end