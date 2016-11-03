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
    assert {:ok, pid, %Temp{} = struct} = Temp.start(sensor_mod, sensor_params, name)

    #assert {:ok, _sup} = Sensor.Supervisor.start_link
    inspect Supervisor.count_children(SensorSupervisor)
    assert struct.value == 20.0

  end
end