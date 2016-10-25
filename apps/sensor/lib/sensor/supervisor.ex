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
    Supervisor.start_child(@name, worker(module, params, name: name))    
  end

  def start_sensor(module, params) do
    Supervisor.start_child(@name, worker(module, params))    
  end    
end