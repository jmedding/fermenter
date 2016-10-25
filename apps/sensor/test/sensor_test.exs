defmodule SensorTest do
  use ExUnit.Case
  doctest Sensor

  alias Sensor.Temp.Dht.Server

  setup do
    {type, gpio, name, sensor_mod} = {11, 4, :temp1, Sensor.Temp.Dht.Server}
    {:ok, type: type, gpio: gpio, name: name, sensor_mod: sensor_mod}
  end

  test "Can start a sensor", %{type: type, gpio: gpio, name: name, sensor_mod: sensor_mod} do
    assert {:ok, _sup} = Sensor.Supervisor.start_link
    assert {:ok, _pid} = Sensor.Supervisor.start_sensor(sensor_mod, [type, gpio, name])
    assert %Server.Reading{ unit: _unit, value: value, status: _status} = Server.read(name)
    assert value == 20.0

  end

  test "temp sensor is restarted by supervisor", %{type: type, gpio: gpio, name: name, sensor_mod: sensor_mod} do
    assert {:ok, sup} = Sensor.Supervisor.start_link
    assert {:ok, pid} = Sensor.Supervisor.start_sensor(sensor_mod, [type, gpio, name])
    assert %Server.Reading{ unit: _unit, value: value, status: _status} = Server.read(name)
    assert value == 20.0
    Sensor.Temp.Dht.Server.set_temp(name, 22)
    assert %Server.Reading{ unit: _unit, value: value, status: _status} = Server.read(name)
    assert value == 22.0
    #assert Process.unlink(pid)
    assert Process.exit(pid, :shutdown)
    # There seems to be delay in the process restart.
    # The inspec call gives enough time for the child to restart
    inspect Supervisor.count_children(sup)
    assert %Server.Reading{ unit: _unit, value: value, status: _status} = Server.read(name)
    assert value == 20.0 #default temp value
    
  end
end
