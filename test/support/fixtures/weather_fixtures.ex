defmodule WeatherApi.WeatherFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `WeatherApi.Weather` context.
  """

  @doc """
  Generate a location.
  """
  def location_fixture(attrs \\ %{}) do
    {:ok, location} =
      attrs
      |> Enum.into(%{
        forecast_url: "some forecast_url",
        lat: "some lat",
        long: "some long",
        name: "some name"
      })
      |> WeatherApi.Weather.create_location()

    location
  end
end
