defmodule WeatherApi.Weather do
  @moduledoc """
  The Weather context.
  """

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
  def get_location!(id), do: Repo.get!(Location, id)

  def get_location_by_name!(name) do
    location = Repo.get_by!(Location, name: name)

    forecasts =
      location.forecast_url
      |> get_forecasts()
      |> Enum.map(&Map.take(&1, ["name", "detailedForecast"]))

    Map.merge(location, %{forecasts: forecasts})
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
    forecast_url = get_location(lat, long) |> dbg
    attrs = Map.merge(attrs, %{"forecast_url" => forecast_url}) |> dbg

    %Location{}
    |> Location.changeset(attrs)
    |> Repo.insert()
  end

  def get_location(lat, long) do
    with req <- Finch.build(:get, "#{@location_base_url}/#{lat},#{long}"),
         {:ok, %{body: body}} <- Finch.request(req, WeatherApi.Finch),
         {:ok, decoded} <- Jason.decode(body) do
      get_in(decoded, ["properties", "forecast"])
    else
      # TODO: PUT ERROR HANDLING IN HERE LATER
      _ -> nil
    end
  end

  def get_forecasts(url) do
    with req <- Finch.build(:get, url),
         {:ok, %{body: body}} <- Finch.request(req, WeatherApi.Finch),
         {:ok, decoded} <- Jason.decode(body) do
      get_in(decoded, ["properties", "periods"])
    else
      # TODO: PUT ERROR HANDLING IN HERE LATER
      _ -> nil
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
