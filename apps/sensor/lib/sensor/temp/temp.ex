defmodule Sensor.Temp do
  @supervisor SensorSupervisor

  defstruct unit: "°C",
            value: -99.9,
            status: :init
  
  def start(module, params, name) do
    :ok = Sensor.Registry.add(name, module)

    count = Supervisor.count_children(@supervisor)
    id = to_string(module) <> "_" <> to_string(count.workers)
    {:ok, pid} = Supervisor.start_child(@supervisor, Supervisor.Spec.worker(module, params ++ [name], id: id))
  end

  def sense(name) do
    case Sensor.Registry.get(name) do
      :not_found -> {:error, "unregistered sensor name: #{name}"}
      module -> module.read(name)
    end
  end
end

