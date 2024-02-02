defmodule WeatherApiWeb.LocationController do
  use WeatherApiWeb, :controller

  alias WeatherApi.Weather
  alias WeatherApi.Weather.Location

  action_fallback WeatherApiWeb.FallbackController

  def index(conn, %{"name" => name}) do
    with %Location{} = location <- Weather.get_location_by_name!(name) do
      render(conn, :show, location: location)
    end
  end

  def index(conn, _params) do
    locations = Weather.list_locations()
    render(conn, :index, locations: locations)
  end

  def create(conn, %{"location" => location_params}) do
    with {:ok, %Location{} = location} <- Weather.create_location(location_params) do
      conn
      |> put_status(:created)
      |> put_resp_header("location", ~p"/api/locations/#{location}")
      |> render(:show, location: location)
    end
  end

  def show(conn, %{"id" => id}) do
    with %Location{} = location <- Weather.get_location!(id) do
      render(conn, :show, location: location)
    end
  end

  def update(conn, %{"id" => id, "location" => location_params}) do
    location = Weather.get_location!(id)

    with {:ok, %Location{} = location} <- Weather.update_location(location, location_params) do
      render(conn, :show, location: location)
    end
  end

  def delete(conn, %{"id" => id}) do
    location = Weather.get_location!(id)

    with {:ok, %Location{}} <- Weather.delete_location(location) do
      send_resp(conn, :no_content, "")
    end
  end
end
