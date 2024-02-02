defmodule WeatherApi.Weather do
  @moduledoc """
  The Weather context.
  """

  require Logger

  import Ecto.Query, warn: false
  alias WeatherApi.Repo

  alias WeatherApi.Weather.Location

  @location_base_url "https://api.weather.gov/points"

  @doc """
  Returns the list of locations.

  ## Examples

      iex> list_locations()
      [%Location{}, ...]

  """
  def list_locations do
    Repo.all(Location)
  end

  @doc """
  Gets a single location.

  Raises `Ecto.NoResultsError` if the Location does not exist.

  ## Examples

      iex> get_location!(123)
      %Location{}

      iex> get_location!(456)
      ** (Ecto.NoResultsError)

  """
  def get_location!(id) do
    Repo.get!(Location, id) |> fetch_forecasts()
  end

  def get_location_by_name!(name) do
    Repo.get_by!(Location, name: name) |> fetch_forecasts()
  end

  @doc """
  Creates a location.

  ## Examples

      iex> create_location(%{field: value})
      {:ok, %Location{}}

      iex> create_location(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_location(%{"lat" => lat, "long" => long} = attrs) do
    with {:ok, forecast_url} <- fetch_forecast_url(lat, long) do
      attrs = Map.put(attrs, "forecast_url", forecast_url)

      %Location{}
      |> Location.changeset(attrs)
      |> Repo.insert()
    end
  end

  @doc """
  Fetches the forecast URL from the API for a location by lat/long.
  """
  def fetch_forecast_url(lat, long) do
    url = "#{@location_base_url}/#{lat},#{long}"

    with req <- Finch.build(:get, url),
         {:ok, %{status: 200, body: body}} <- Finch.request(req, WeatherApi.Finch),
         {:ok, decoded} <- Jason.decode(body) do
      {:ok, get_in(decoded, ["properties", "forecast"])}
    else
      _ ->
        Logger.error("There was a problem with the response from #{url}")
        {:error, :external}
    end
  end

  @doc """
  Fetches the detailed forecast from a forecast URL.
  """
  def fetch_forecasts(%Location{} = location) do
    with req <- Finch.build(:get, location.forecast_url),
         {:ok, %{status: 200, body: body}} <- Finch.request(req, WeatherApi.Finch),
         {:ok, decoded} <- Jason.decode(body) do
      forecasts =
        decoded
        |> get_in(["properties", "periods"])
        |> Enum.map(&Map.take(&1, ["name", "detailedForecast"]))

      Location.put_forecasts(location, forecasts)
    else
      _ ->
        Logger.error("There was a problem with the response from #{location.forecast_url}")
        {:error, :external}
    end
  end

  @doc """
  Updates a location.

  ## Examples

      iex> update_location(location, %{field: new_value})
      {:ok, %Location{}}

      iex> update_location(location, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_location(%Location{} = location, attrs) do
    location
    |> Location.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a location.

  ## Examples

      iex> delete_location(location)
      {:ok, %Location{}}

      iex> delete_location(location)
      {:error, %Ecto.Changeset{}}

  """
  def delete_location(%Location{} = location) do
    Repo.delete(location)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking location changes.

  ## Examples

      iex> change_location(location)
      %Ecto.Changeset{data: %Location{}}

  """
  def change_location(%Location{} = location, attrs \\ %{}) do
    Location.changeset(location, attrs)
  end
end
