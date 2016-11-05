defmodule Sensor do
  use Application
  @name SensorSupervisor

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [ worker(Sensor.Registry, []) ]
    opts = [strategy: :one_for_one, name: @name]
    Supervisor.start_link(children, opts)
  end

  @spec start_sensor(module, integer, integer, atom) :: {atom, pid}
  def start_sensor(module, dht_type, gpio, name) do
    count = Supervisor.count_children(@name)
    id = to_string(module) <> "_" <> to_string(count.workers)
    Supervisor.start_child(@name, Supervisor.Spec.worker(module, [dht_type, gpio, name], id: id))
  end 
end
