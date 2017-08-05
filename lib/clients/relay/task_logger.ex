defmodule Relay.TaskLogger do
  @moduledoc false
  def log_task_event(job, campaign, state) do
    IO.puts("\n\n\nJOB====")
    IO.inspect(job)
    existing_task = Core.Repo.get_by(Core.RelayTask, job_id: job.id)
    schema = if (existing_task == nil), do: %Core.RelayTask{}, else: existing_task

    cs = Core.RelayTask.changeset(schema, %{:job_id=> job.id, :campaign_id=>campaign.campaign_id, :status=>state})
    Core.Repo.insert_or_update(cs)
  end

end