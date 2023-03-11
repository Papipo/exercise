defmodule Remote.PointsServerTest do
  use Remote.DataCase
  alias Remote.PointsServer
  import Remote.Factories

  test "init" do
    {:ok, {min_number, nil}} = PointsServer.init(refresh_interval: 1)
    assert min_number in 0..100
    assert_receive({:refresh, 1})
  end

  test "handle_call(:fetch)" do
    for points <- 1..10 do
      insert!(:user, points: points)
    end

    timestamp = DateTime.utc_now()

    {:reply, payload, {5, timestamp}} = PointsServer.handle_call(:fetch, self(), {5, timestamp})

    assert length(payload.users) == 2
    assert Enum.all?(payload.users, &(&1.points > 5))

    allowed_ids =
      Remote.User.Queries.points_higher_than(5)
      |> Repo.all()
      |> Enum.map(&Map.fetch!(&1, :id))

    returned_ids = Enum.map(payload.users, & &1.id)

    assert MapSet.subset?(MapSet.new(returned_ids), MapSet.new(allowed_ids))
  end

  test "handle_info(:refresh)" do
    for _points <- 1..100 do
      insert!(:user, points: 0)
    end

    assert from(u in Remote.User, where: u.points == 0) |> Repo.aggregate(:count) == 100

    assert {:noreply, {min_number, nil}} = PointsServer.handle_info({:refresh, 1}, {50, nil})

    assert min_number in 0..100
    assert_receive({:refresh, 1})
    assert from(u in Remote.User, where: u.points > 0) |> Repo.aggregate(:count) > 0
  end
end
