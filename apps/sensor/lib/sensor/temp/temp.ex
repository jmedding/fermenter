defmodule Sensor.Temp do
  
end

defprotocol TempSensor do
  @doc """
  Returns a valid temperature value {:ok, {"°C", 22.3}} or an 
  error message {:error, :invalid, "The sensor is getting weird results, don't trust"}
  """
  def sense(temp_sensor)
end