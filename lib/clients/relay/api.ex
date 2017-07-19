defmodule Relay.Api do
    use HTTPotion.Base
  @moduledoc false

  @relay_account Application.get_env(:core, :relay_account)
  @relay_key Application.get_env(:core, :relay_key)

  defp process_url(url) do
    foo = "https://api.relaytxt.io/v1/accounts/#{@relay_account}/" <> url
    IO.inspect(foo)
    foo
  end

  defp process_request_headers(hdrs) do
    Enum.into(hdrs, ["Authorization": "Token token=#{@relay_key}"])
  end

  
end