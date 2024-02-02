defmodule WeatherApi.WeatherTest do
  use WeatherApi.DataCase

  alias WeatherApi.Weather

  describe "locations" do
    alias WeatherApi.Weather.Location

    import WeatherApi.WeatherFixtures

    @invalid_attrs %{name: nil, long: nil, lat: nil, forecast_url: nil}

    test "list_locations/0 returns all locations" do
      location = location_fixture()
      assert Weather.list_locations() == [location]
    end

    test "get_location!/1 returns the location with given id" do
      location = location_fixture()
      assert Weather.get_location!(location.id) == location
    end

    test "create_location/1 with valid data creates a location" do
      valid_attrs = %{name: "some name", long: "some long", lat: "some lat", forecast_url: "some forecast_url"}

      assert {:ok, %Location{} = location} = Weather.create_location(valid_attrs)
      assert location.name == "some name"
      assert location.long == "some long"
      assert location.lat == "some lat"
      assert location.forecast_url == "some forecast_url"
    end

    test "create_location/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Weather.create_location(@invalid_attrs)
    end

    test "update_location/2 with valid data updates the location" do
      location = location_fixture()
      update_attrs = %{name: "some updated name", long: "some updated long", lat: "some updated lat", forecast_url: "some updated forecast_url"}

      assert {:ok, %Location{} = location} = Weather.update_location(location, update_attrs)
      assert location.name == "some updated name"
      assert location.long == "some updated long"
      assert location.lat == "some updated lat"
      assert location.forecast_url == "some updated forecast_url"
    end

    test "update_location/2 with invalid data returns error changeset" do
      location = location_fixture()
      assert {:error, %Ecto.Changeset{}} = Weather.update_location(location, @invalid_attrs)
      assert location == Weather.get_location!(location.id)
    end

    test "delete_location/1 deletes the location" do
      location = location_fixture()
      assert {:ok, %Location{}} = Weather.delete_location(location)
      assert_raise Ecto.NoResultsError, fn -> Weather.get_location!(location.id) end
    end

    test "change_location/1 returns a location changeset" do
      location = location_fixture()
      assert %Ecto.Changeset{} = Weather.change_location(location)
    end
  end
end
