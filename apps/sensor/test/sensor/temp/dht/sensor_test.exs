defmodule Sensor.Temp.Dht.ServerTest do
  use ExUnit.Case
  doctest Sensor

  alias Sensor.Temp.Dht.Server
  alias Sensor.Temp.Dht.Server.Reading

  setup do
    {type, gpio, name} = {11, 4, :temp1}
    {:ok, type: type, gpio: gpio, name: name}
  end

  test "can start a temp sensor", %{type: type, gpio: gpio, name: name} do
    assert {:ok, _PID} = Server.start_link(type, gpio, name)
  end

  test "can get the temperature", %{type: type, gpio: gpio, name: name} do
    assert {:ok, _PID} = Server.start_link(type, gpio, name)
    assert %Reading{ unit: _unit, value: value, status: _status} = Server.read(:temp1)
    assert value == 20.0
  end

  test "can monitor the same sensor", %{type: type, gpio: gpio, name: name} do
    assert {:ok, _PID} = Server.start_link(type, gpio, name)
    assert {:ok, _PID} = Server.start_link(type, gpio, :other_name)
  end

  test "cannot reuse a sensor link name", %{type: type, gpio: gpio, name: name} do
    assert {:ok, pid} = Server.start_link(type, gpio, name)
    assert {:error, {:already_started, ^pid}} = Server.start_link(type, gpio, name)
  end

  test "can set the dht values", %{type: type, gpio: gpio, name: name} do
    assert {:ok, _pid} = Server.start_link(type, gpio, name)
    assert %Reading{ unit: _unit, value: value, status: _status}  = Server.set_temp(name, 22)
    assert value == 22.0
    assert %Reading{ unit: _unit, value: value, status: _status} = Server.read(:temp1)
    assert value == 22.0
  end

  test "can monitor two sensors", %{type: type} do
    assert {:ok, _pid} = Server.start_link(type, 4, :t4)
    assert {:ok, _pid} = Server.start_link(type, 5, :t5)
    assert %Reading{ unit: _unit, value: val_a, status: _status} = Server.set_temp(:t4, 22)
    assert val_a == 22.0
    assert %Reading{ unit: _unit, value: val_b, status: _status} = Server.set_temp(:t5, 24)
    assert val_b == 24.0
    assert %Reading{ unit: _unit, value: val_a, status: _status} = Server.read(:t4)
    assert val_a == 22.0
    assert %Reading{ unit: _unit, value: val_b, status: _status} = Server.read(:t5)
    assert val_b == 24.0
  

  end


end
