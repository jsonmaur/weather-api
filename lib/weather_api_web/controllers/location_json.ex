defmodule WeatherApiWeb.LocationJSON do
  alias WeatherApi.Weather.Location

  @doc """
  Renders a list of locations.
  """
  def index(%{locations: locations}) do
    %{data: for(location <- locations, do: data(location))}
  end

  @doc """
  Renders a single location.
  """
  def show(%{location: location}) do
    %{data: data(location)}
  end

  defp data(%Location{} = location) do
    %{
      id: location.id,
      name: location.name,
      lat: location.lat,
      long: location.long,
      forecast_url: location.forecast_url,
      forecasts: location.forecasts
    }
  end
end
