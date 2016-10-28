defmodule Sensor do
  use Application
  @name SensorSupervisor

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = []
    opts = [strategy: :one_for_one, name: @name]
    Supervisor.start_link(children, opts)
  end

  def start_sensor(module, params) do
    Supervisor.start_child(@name, Supervisor.Spec.worker(module, params))
    IO.puts inspect Supervisor.count_children(@name)  
  end 
end
