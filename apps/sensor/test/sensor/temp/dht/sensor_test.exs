defmodule Sensor.Temp.DhtTest do
  use ExUnit.Case
  doctest Sensor

  alias Sensor.Temp.Dht

  setup do
    {type, gpio, name} = {11, 4, :temp1}
    {:ok, type: type, gpio: gpio, name: name}
  end
  
  describe "Sensor.Temp.Dht" do
    test "can start a temp sensor", %{type: type, gpio: gpio, name: name} do
      assert {:ok, _PID} = Dht.start_link(type, gpio, name)
    end

    test "can get the temperature", %{type: type, gpio: gpio, name: name} do
      assert {:ok, _PID} = Dht.start_link(type, gpio, name)
      assert %Sensor.Temp{ unit: _unit, value: value, status: _status} = Dht.read(name)
      assert value == 20.0
    end

    test "can monitor the same sensor", %{type: type, gpio: gpio, name: name} do
      assert {:ok, _PID} = Dht.start_link(type, gpio, name)
      assert {:ok, _PID} = Dht.start_link(type, gpio, :other_name)
    end

    test "cannot reuse a sensor link name", %{type: type, gpio: gpio, name: name} do
      assert {:ok, pid} = Dht.start_link(type, gpio, name)
      assert {:error, {:already_started, ^pid}} = Dht.start_link(type, gpio, name)
    end

    test "can set the dht values", %{type: type, gpio: gpio, name: name} do
      assert {:ok, _pid} = Dht.start_link(type, gpio, name)
      assert :ok = Dht.set_temp(name, 22)
      assert %Sensor.Temp{ unit: _unit, value: value, status: _status} = Dht.read(name)
      assert value == 22.0
    end

    test "can monitor two sensors", %{type: type} do
      assert {:ok, _pid} = Dht.start_link(type, 4, :t4)
      assert {:ok, _pid} = Dht.start_link(type, 5, :t5)
      assert :ok = Dht.set_temp(:t4, 22)
      assert %Sensor.Temp{ value: val_a} = Dht.read(:t4)
      assert val_a == 22.0
      assert :ok = Dht.set_temp(:t5, 24)
      assert %Sensor.Temp{ value: val_b} = Dht.read(:t5)
      assert val_b == 24.0
      assert %Sensor.Temp{ value: val_a} = Dht.read(:t4)
      assert val_a == 22.0
      assert %Sensor.Temp{ value: val_b} = Dht.read(:t5)
      assert val_b == 24.0
    end
  end

end
