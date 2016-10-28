defmodule SensorTest do
  use ExUnit.Case
  doctest Sensor

  alias Sensor.Temp.Dht.Server

  setup do
    #Application.stop :sensor
    {type, gpio, name} = {11, 4, :temp1}
    sensor_mod = Sensor.Temp.Dht.Server
    {:ok, type: type, gpio: gpio, name: name, sensor_mod: sensor_mod}
  end

  test "Can start a sensor", %{type: type, gpio: gpio, sensor_mod: sensor_mod} do
    name = :a
    #assert {:ok, _sup} = Sensor.Supervisor.start_link
    assert {:ok, pid} = Sensor.Supervisor.start_sensor(sensor_mod, [type, gpio, name])
    Process.exit(pid, :shutdown)
    inspect Supervisor.count_children(SensorSupervisor)
    inspect Supervisor.count_children(SensorSupervisor)
    assert %Server.Reading{ unit: _unit, value: value, status: _status} = Server.read(name)
    assert value == 20.0

  end

  test "temp sensor is restarted by supervisor", %{type: type, gpio: gpio, sensor_mod: sensor_mod} do
    name = :b
    sup = Process.whereis SensorSupervisor
    #assert {:ok, sup} = Sensor.Supervisor.start_link
    assert {:ok, pid} = Sensor.Supervisor.start_sensor(sensor_mod, [type, gpio, name])
    assert %Server.Reading{ unit: _unit, value: value, status: _status} = Server.read(name)
    assert value == 20.0
    Sensor.Temp.Dht.Server.set_temp(name, 22)
    assert %Server.Reading{ unit: _unit, value: value, status: _status} = Server.read(name)
    assert value == 22.0
    assert Process.exit(pid, :shutdown)
    # There seems to be delay in the process restart.
    # The inspec call gives enough time for the child to restart
    inspect Supervisor.count_children(sup)
    inspect Supervisor.count_children(sup)
    assert %Server.Reading{ unit: _unit, value: value, status: _status} = Server.read(name)
    assert value == 20.0 #default temp value

    
  end
end
