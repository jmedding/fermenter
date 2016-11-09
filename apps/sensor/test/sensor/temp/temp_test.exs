defmodule TempTest do
  use ExUnit.Case
  doctest Sensor.Temp

  alias Sensor.Temp

  setup do
    #Application.stop :sensor
    {type, gpio} = {11, 4}
    sensor_mod = Sensor.Temp.Dht
    {:ok, type: type, gpio: gpio, sensor_mod: sensor_mod}
  end

  describe "Manage a sensor with just a name, can be any type of temp sensor" do
    test "Can start a DHT temp sensor", %{type: type, gpio: gpio, sensor_mod: sensor_mod} do
      sensor_params = [type, gpio]
      name = :temp_c
      assert {:ok, _pid} = Temp.start(sensor_mod, sensor_params, name)
      assert %Temp{} = struct = Temp.sense(:temp_c)
      assert struct.value == 20.0
    end

    test "Cannot start a sensor with the same name", %{type: type, gpio: gpio, sensor_mod: sensor_mod} do
      sensor_params = [type, gpio]
      other_params = [type, gpio + 1]
      name = :temp_b
      assert {:ok, _pid} = Temp.start(sensor_mod, sensor_params, name)
      assert {:error, _msg} = Temp.start(sensor_mod, other_params, name)
    end

    test "Will not register a name if start fails", %{type: type, gpio: gpio, sensor_mod: sensor_mod} do
      sensor_params = [type, gpio]
      bad_params = [0,0]
      name = :temp_d
      assert {:error, _message} = Temp.start(sensor_mod, bad_params, name)
      assert {:ok, _pid} = Temp.start(sensor_mod, sensor_params, name)
      assert %Temp{} = struct = Temp.sense(:temp_d)
      assert struct.value == 20.0
    end

    test "temp sensor is restarted by supervisor", %{type: type, gpio: gpio, sensor_mod: sensor_mod} do
      name = :b
      sensor_params = [type, gpio]
      assert {:ok, pid} = Temp.start(sensor_mod, sensor_params, name)
      assert %Temp{ value: value } = Temp.sense(name)
      assert value == 20.0
      sensor_mod.set_temp(name, 22)
      assert %Temp{ value: value } = sensor_mod.read(name)
      assert value == 22.0
      assert Process.exit(pid, :shutdown)
      # There seems to be delay in the process restart.
      # The inspec call gives enough time for the child to restart
      inspect Supervisor.count_children(SensorSupervisor)
      inspect Supervisor.count_children(SensorSupervisor)
      assert %Temp{ value: value } = sensor_mod.read(name)
      assert value == 20.0 #default temp value
    end

    test "Can start more than one sensor", %{type: type, gpio: gpio, sensor_mod: sensor_mod} do
      {name1, name2} = {:c, :d}
      assert {:ok, _pid} = Temp.start(sensor_mod, [type, gpio], name1)
      assert {:ok, _pid} = Temp.start(sensor_mod, [type, gpio], name2)
      inspect Supervisor.count_children(SensorSupervisor)
      inspect Supervisor.count_children(SensorSupervisor)
      sensor_mod.set_temp(name1, 22)
      assert %Temp{ value: value1 } = sensor_mod.read(name1)
      assert %Temp{ value: value2 } = sensor_mod.read(name2)
      assert value1 == 22.0
      assert value2 == 20.0
    end

    test "Does not blow up if it tries to sense a bad name", %{type: type, gpio: gpio, sensor_mod: sensor_mod} do
      sensor_params = [type, gpio]
      name = :temp_e
      assert {:ok, _pid} = Temp.start(sensor_mod, sensor_params, name)
      assert %Temp{} = struct = Temp.sense(:temp_e)
      assert struct.value == 20.0
      assert {:error, _msg} = Temp.sense(:does_not_exist)
    end

    test "Create two sensors from different types" do
      #Need to create a second sensor type first
    end
  end
end