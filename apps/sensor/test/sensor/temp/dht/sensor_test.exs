defmodule Sensor.Temp.Dht.ServerTest do
  use ExUnit.Case
  doctest Sensor

  alias Sensor.Temp.Dht.Server

  setup do
    {type, gpio, name} = {11, 4, :temp1}
    {:ok, type: type, gpio: gpio, name: name}
  end

  test "can start a temp sensor", %{type: type, gpio: gpio, name: name} do
    assert {:ok, _PID} = Server.start_link(type, gpio, name)
  end

  test "can get the temperature", %{type: type, gpio: gpio, name: name} do
    assert {:ok, _PID} = Server.start_link(type, gpio, name)
    assert %Server.Reading{ unit: _unit, value: value, status: _status} = Server.read(:temp1)
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
    assert %Server.Reading{ unit: _unit, value: value, status: _status}  = Server.set_temp(name, 22)
    assert value == 22.0
    assert %Server.Reading{ unit: _unit, value: value, status: _status} = Server.read(:temp1)
    assert value == 22.0
  end


end
