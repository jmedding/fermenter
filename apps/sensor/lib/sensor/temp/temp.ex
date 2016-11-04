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

  def sense(struct) do
    struct.module.read struct.name
  end
end

