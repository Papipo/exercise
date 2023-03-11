# Remote PointsServer

To start your Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * This seed the database with one million users.
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

# GET / Endpoint

There is a single enpoint that under the hood just calls `PointsServer.fetch()`.
It will just return whatever the GenServer did.

# PointsServer

A supervised GenServer registered under its own name.

Used to return at most 2 users from the database that have more points than a random value that the GenServer keeps in its state.

It also periodically randomizes that value and the points for all users in the database.

For details and options check [its source code](lib/remote/points_server.ex)

# Implementation

I started by writing an [integration test](test/remote_web/controllers/root_controller_test.exs).
Once I understand the specifications of the feature/task, I always try to go outside-in.

When you run this test it keeps telling you what's the next step: adding the endpoint to the router, create the controller, implement the action, etc.
Then I had to implenent the GenServer, which AFAIK is nothing special.

## How to test that the GenServer refreshes?

I decided to add the option to pass the refreshing interval because:

- It's better not to hardcode this kind of thing (providing a default is fine)
- Allows me to set a very quick interval and be able to test the refresh behaviour in a test using `assert_receive`.

## Refreshing points

I decided to run a raw SQL update to randomize all users at once. It seemed the most straightforward way and also it's the most performant AFAIK.
