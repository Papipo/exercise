defmodule Remote.PointsServer do
  @moduledoc """
  A supervised GenServer registered under its own name.
  Periodically randomizes the points of the users in the database.
  Check `init/1` to see how you can specify the interval.
  """
  use GenServer
  import Remote.User.Queries
  import Ecto.Query
  alias Remote.Repo

  @type payload :: %{
          timestamp: nil | integer(),
          users: [%{id: integer(), points: integer()}]
        }

  @spec fetch() :: payload()
  @doc """
  Fetch up to 2 users from the database that have more points than the current min_number.
  It will also return the timestamp of the last call to fetch() (nil if this is the first call).
  """
  def fetch() do
    GenServer.call(__MODULE__, :fetch)
  end

  @impl true
  def handle_call(:fetch, _from, {min_number, timestamp}) do
    payload = %{
      timestamp: timestamp,
      users: points_higher_than(min_number) |> limit(2) |> Repo.all()
    }

    {:reply, payload, {min_number, DateTime.utc_now()}}
  end

  @impl true
  def handle_info({:refresh, interval}, state) do
    Task.start(Remote.User, :randomize_points, [])
    schedule_refresh(interval)

    {:noreply, {random_min_number(), elem(state, 1)}}
  end

  @impl true
  @doc """
  Supports a single Keyword option: :refresh_interval (1 minute by default).
  This is the interval (in milliseconds) used by the GenServer to randomize the values of the points for all users in the database.
  """
  def init(opts) do
    Keyword.get(opts, :refresh_interval, :timer.minutes(1))
    |> schedule_refresh()

    {:ok, {random_min_number(), nil}}
  end

  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @spec schedule_refresh(non_neg_integer()) :: reference()
  defp schedule_refresh(interval) do
    Process.send_after(self(), {:refresh, interval}, interval)
  end

  @spec random_min_number() :: non_neg_integer()
  defp random_min_number() do
    Enum.random(0..100)
  end
end
