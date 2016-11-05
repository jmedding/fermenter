defmodule Sensor.RegistryTest do
  use ExUnit.Case
  alias Sensor.Registry

  test "add to and get from regsitry" do
    assert :ok = Registry.add :temp1, Sensor.Temp.Dht.Server
    assert Sensor.Temp.Dht.Server = Registry.get :temp1
  end
end