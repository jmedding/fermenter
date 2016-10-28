defmodule Sensor.Supervisor do
  use   Supervisor
  @name SensorSupervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: @name)
  end

  def init([]) do
    children = []
    supervise(children, strategy: :one_for_one)
  end

  def start_sensor(module, params, name) do
    Supervisor.start_child(@name, worker(module, params, id: name))    
  end

  def start_sensor(module, params) do
    IO.puts inspect params
    count = Supervisor.count_children(@name)
    id = to_string(module) <> "_" <> to_string(count.workers)
    # must add a unique id to worker otherwise starting a second sensor of
    # of the same type (or module) will crash, with :all_ready_started error
    Supervisor.start_child(@name, worker(module, params, id: id))
  end    
end