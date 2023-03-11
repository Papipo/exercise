defmodule RemoteWeb.RootJSON do
  def index(%{payload: payload}) do
    %{payload | users: Enum.map(payload.users, &Map.take(&1, [:id, :points]))}
  end
end
