defmodule RemoteWeb.RootControllerTest do
  use RemoteWeb.ConnCase
  import Remote.Factories

  test "GET /" do
    payload =
      build_conn()
      |> put_req_header("accept", "application/json")
      |> get("/")
      |> json_response(200)

    first_call_at = DateTime.utc_now()

    payload =
      build_conn()
      |> put_req_header("accept", "application/json")
      |> get("/")
      |> json_response(200)

    {:ok, second_call_at, 0} = DateTime.from_iso8601(payload["timestamp"])

    # We are not inserting users because the min_number in PointsServer can be 100
    # and that would mean that no users would be returned, so we just check that a
    # list is returned. After all the logic in the controller action is a single
    # line.
    assert is_list(payload["users"])

    assert Time.diff(first_call_at, second_call_at, :millisecond) <= 50
  end
end
