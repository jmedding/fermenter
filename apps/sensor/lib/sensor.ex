defmodule Sensor do
  use Application
  @name SensorSupervisor

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [ ]
    opts = [strategy: :one_for_one, name: @name]
    Supervisor.start_link(children, opts)
  end

end
