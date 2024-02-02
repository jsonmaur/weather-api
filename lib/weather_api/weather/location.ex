defmodule WeatherApi.Weather.Location do
  use Ecto.Schema
  import Ecto.Changeset

  schema "locations" do
    field :name, :string
    field :lat, :float
    field :long, :float
    field :forecast_url, :string
    field :forecasts, {:array, :map}, virtual: true

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(location, attrs) do
    location
    |> cast(attrs, [:name, :lat, :long, :forecast_url])
    |> validate_required([:name, :lat, :long, :forecast_url])
    |> validate_length(:name, max: 255)
    |> validate_number(:lat, less_than_or_equal_to: 90, greater_than_or_equal_to: -90)
    |> validate_number(:long, less_than_or_equal_to: 180, greater_than_or_equal_to: -180)
    |> validate_length(:forecast_url, max: 100)
    |> unique_constraint(:name)
  end
end
