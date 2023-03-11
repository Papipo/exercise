defmodule Remote.Factories do
  alias Remote.Repo

  # Factories

  def build(:user) do
    %Remote.User{points: Enum.random(0..100)}
  end

  # Convenience API

  def build(factory_name, attributes) do
    factory_name |> build() |> struct!(attributes)
  end

  def insert!(factory_name, attributes \\ []) do
    factory_name |> build(attributes) |> Repo.insert!()
  end
end
