defmodule RemoteWeb.RootController do
  use RemoteWeb, :controller

  def index(conn, _params) do
    payload = Remote.PointsServer.fetch()

    render(conn, :index, payload: payload)
  end
end
