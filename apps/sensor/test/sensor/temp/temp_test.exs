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

  describe "Manage a sensor with just a name, can be any type of temp sensor" do
    test "Can start a DHT temp sensor", %{type: type, gpio: gpio, sensor_mod: sensor_mod} do
      sensor_params = [type, gpio]
      name = :temp_c
      assert {:ok, _pid} = Temp.start(sensor_mod, sensor_params, name)
      assert %Temp{} = struct = Temp.sense(:temp_c)
      assert struct.value == 20.0
    end

    test "Create two sensors from different types" do
      #Need to create a second sensor type first
    end
  end
end