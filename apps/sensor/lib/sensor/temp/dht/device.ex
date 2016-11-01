
defmodule Sensor.Temp.Dht.Device do
  
@moduledoc """
This module will read the DHT temp sensor and prcoess
the result into an elixir value
"""

  @doc ~S"""
  Gets the temperature measurement from the sensor

  ## Examples

      iex> TempSense.read
      {:ok, %{temp: 20.0, humidity: 34.0}}

  """
  def read(type, gpio) do
    call_sensor(type, gpio)
    |> parse_result
  end

  defp parse_result(result) do
    # result looks like "Temp=20.0*  Humidity=34.0%\n"
    match = Regex.named_captures(~r/Temp=(?<temp>.+)\*.+Humidity=(?<humidity>.+)%/, result)

    case match do
      %{"temp" => t, "humidity" => h} -> 
          {:ok, %{temp: String.to_float(t), humidity: String.to_float(h)}}
      _ -> 
          {:error, result}
    end
  end

  defp call_sensor(type, pin) do

    #IO.inspect(Mix.env())

    # Should be able to remove this case statement as we use config.ex to inject test_device for non-prod
    result = case Mix.env do
      :test -> result = {"Temp=20.0*C  Humidity=34.0%\n", 0}
      :prod -> result = System.cmd("python", ["bin/DHT.py", to_string(type), to_string(pin)])
      _     -> result = {"Temp=22.2*C  Humidity=33.3%\n", 0}
    end
    
    case result do
      {txt, 0} ->
        txt
      {_, err} when err > 0 ->
        "OS level sensor error"
      _ ->
        "Unexpected result from call_sensor"
    end
  end

  defmodule SensorError do
    defexception message: "Sensor error"
  end
end