defmodule WeatherApi.Repo.Migrations.CreateLocations do
  use Ecto.Migration

  def change do
    create table(:locations) do
      add :name, :string
      add :lat, :float
      add :long, :float
      add :forecast_url, :string

      timestamps(type: :utc_datetime)
    end

    create unique_index(:locations, [:name])
  end
end
