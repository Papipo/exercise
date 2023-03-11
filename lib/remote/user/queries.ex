defmodule Remote.User.Queries do
  import Ecto.Query
  alias Remote.User

  def points_higher_than(nil) do
    from(u in User)
  end

  def points_higher_than(num) do
    from(u in User, where: u.points > ^num)
  end
end
