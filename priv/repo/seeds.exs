# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Remote.Repo.insert!(%Remote.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Remote.{User, Repo}

Repo.delete_all(User, log: false)

timestamp = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

IO.puts("Inserting 1 million users...")

Stream.cycle([%{points: 0, inserted_at: timestamp, updated_at: timestamp}])
|> Stream.take(1_000_000)
# the maximum parameters postgresql protocol can handle is 65535
|> Stream.chunk_every(20000)
|> Stream.map(&Task.async(fn -> Repo.insert_all(User, &1, log: false) end))
|> Enum.each(&Task.await/1)

IO.puts("Done.")
