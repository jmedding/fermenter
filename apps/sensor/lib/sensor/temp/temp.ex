defmodule Sensor.Temp do
  @supervisor SensorSupervisor

  defstruct module: "genserver",
            name: :atom,
            unit: "°C",
            value: -99.9,
            status: :init
  
  def start(module, params, name) do
    count = Supervisor.count_children(@supervisor)
    id = to_string(module) <> "_" <> to_string(count.workers)
    {:ok, pid, struct} = Supervisor.start_child(@supervisor, Supervisor.Spec.worker(module, params ++ [name], id: id))
  end
end

defprotocol TempSensor do
  @doc """
  Returns a valid temperature value {:ok, {"°C", 22.3}} or an 
  error message {:error, :invalid, "The sensor is getting weird results, don't trust"}
  """
  def sense(temp_sensor_name_or_pid)
end