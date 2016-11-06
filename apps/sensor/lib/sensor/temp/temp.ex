defmodule Sensor.Temp do
  @supervisor SensorSupervisor

  defstruct unit: "°C",
            value: -99.9,
            status: :init
  
  @doc """
  Will first regesiter the name and fail if it is already registered
  Will then attempt to start the supervised sensr process
  If this fails, it will unregister the name and sent the errr message
  """
  def start(module, params, name) do
    with :ok <- Sensor.Registry.add(name, module),
         {:ok, pid} <- Supervisor.start_child(@supervisor, build_spec(module, params, name)) 
      do {:ok, pid}
    else
      {:error, msg} -> 
          :ok = Sensor.Registry.remove(name)
          {:error, msg}
    end
  end

  @doc """
  Generic sense commard for any type of sensor that follows this patter
  TODO: think about how  protocal could be used to enforce this pattern
  """
  def sense(name) do
    case Sensor.Registry.get(name) do
      :not_found -> {:error, "unregistered sensor name: #{name}"}
      module -> module.read(name)
    end
  end

  defp build_spec(module, params, name) do
    count = Supervisor.count_children(@supervisor)
    id = to_string(module) <> "_" <> to_string(count.workers)
    Supervisor.Spec.worker(module, params ++ [name], id: id)
  end
end

