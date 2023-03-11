defmodule Remote.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :points, :integer

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:points])
    |> validate_required([:points])
    |> validate_inclusion(:points, 0..100)
  end

  def randomize_points() do
    query = """
    UPDATE users SET points = RANDOM() * 100
    """

    Ecto.Adapters.SQL.query!(Remote.Repo, query, [])
  end
end
