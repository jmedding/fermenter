defmodule TempTest do
  use ExUnit.Case
  doctest Sensor.Temp

  alias Sensor.Temp

  setup do
    #Application.stop :sensor
    {type, gpio, name} = {11, 4, :temp1}
    sensor_mod = Sensor.Temp.Dht.Server
    {:ok, type: type, gpio: gpio, name: name, sensor_mod: sensor_mod}
  end

  test "Can start a DHT temp sensor", %{type: type, gpio: gpio, sensor_mod: sensor_mod} do
    sensor_params = [type, gpio]
    name = :temp_a
    assert {:ok, _pid, %Sensor.Temp{module: sensor_mod} = struct} = Temp.start(sensor_mod, sensor_params, name)
    inspect Supervisor.count_children(SensorSupervisor)
    assert struct.value == 20.0
  end

  test "Can read a DHT temp sensor", %{type: type, gpio: gpio, sensor_mod: sensor_mod} do
    sensor_params = [type, gpio]
    name = :temp_b
    assert {:ok, _pid, %Sensor.Temp{module: sensor_mod} = struct} = Temp.start(sensor_mod, sensor_params, name)
    inspect Supervisor.count_children(SensorSupervisor)
    assert struct.value == 20.0
    struct.module.set_temp struct.name, 22.2
    assert %Sensor.Temp{value: 22.2, status: :ok} = Temp.sense(struct)

  end
end