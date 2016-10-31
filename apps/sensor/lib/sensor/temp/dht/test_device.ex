defmodule Sensor.Temp.Dht.TestDevice do
@moduledoc """
This module will simulate the DHT temp sensor 
"""

  @doc ~S"""
  Gets the temperature measurement from the sensor

  ## Examples

      iex> TempSense.read
      {:ok, %{temp: 20.0, humidity: 34.0}}

  """
  def read(_type, _gpio) do
    {:ok, %{temp: 20.0, humidity: 34.0}}
  end

  defmodule SensorError do
    defexception message: "Sensor error"
  end
end