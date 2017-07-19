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
    IO.inspect(Map.fetch(bar, "data"))
    render( conn, "index.html", brand: "bnc", mobile: false)
  end
end