defmodule Sensor.Registry do
  use GenServer

  @sensorRegistry Sensor.Registry
  @moduledoc """
  This is a registry to track sensor names and modules

  For example 
    temp1: Sensor.Temp.Dht.Server

  This way, the user only needs to know the sensor name, nut not the
  underying module.
  """

  # Api
  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: @sensorRegistry)
  end

  def add(name, module) do
    GenServer.call(@sensorRegistry, {:add, name, module})
  end

  def get(name) do
    GenServer.call(@sensorRegistry, {:get, name})
  end

  def remove(name) do
    GenServer.call(@sensorRegistry, {:remove, name})
  end

  # Server callbacks
  def init(:ok), do: {:ok, %{}}

  def handle_call({:add, name, module}, _from, state_map) do
    case Map.has_key?(state_map, name) do
      true -> {:reply, {:error, "name <#{name}> already exists with module <#{module}."}, state_map}
      false -> {:reply, :ok, Map.put_new(state_map, name, module)}
    end
  end

  def handle_call({:get, name}, _from, state_map) do
    {:reply, Map.get(state_map, name, :not_found), state_map}
  end

  def handle_call({:remove, name}, _from, state_map) do
    {:reply, :ok, Map.delete(state_map, name)}
  end

end