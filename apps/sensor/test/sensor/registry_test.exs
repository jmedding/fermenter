defmodule Sensor.RegistryTest do
  use ExUnit.Case
  alias Sensor.Registry

  describe "Sensor.Registry" do
    test "add to and get from Regsitry" do
      assert :ok = Registry.add :temp1, Sensor.Temp.Dht
      assert Sensor.Temp.Dht = Registry.get :temp1
    end

    test "remove from Registry" do
      assert :ok = Registry.add(:bad, Sensor.Temp.Dht)
      assert :ok = Registry.remove(:bad)
      assert :not_found = Registry.get(:bad)
    end
  end
end