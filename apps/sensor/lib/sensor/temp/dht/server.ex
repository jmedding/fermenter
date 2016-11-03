defmodule Sensor.Temp.Dht.Server do
@moduledoc """
Get temperature values using the DHT family of sensors

This is implemented with the Adafruit_DHT library and will work for Rpi and Rpi2

It can be initialize with three parameters, (DhtType, pin, name) where name is an atom

The sensor will be pooled at 5 second intervals. Calling the read functoin will
return the last reading, without waiting for a new read. This is because the 
reading process is somewhat slow, especially if the sensor returns an error, in which
case, it will pause and then try again.
"""


  use GenServer

   @device Application.get_env(:sensor, :sensor_temp_dht)

  defmodule Reading do
    defstruct unit: "°C", value: -99.0, status: :init
  end

  ## API callbacks

  @doc """
  Starts the DHT temp sensor server.
  type is to identify which type of DHT (11 | 22)
  gpio is the gpio number the sensor is attached to (ex: 4)
  if gpio==4 then this server will be named DHT4
  """

  @spec start_link(Integer, Integer, :atom) :: {atom, pid}
  def start_link(type, gpio, name) when is_atom(name) and type in [11, 22] do
    IO.puts "starting " <>  to_string(name)
    {:ok, pid} = GenServer.start_link(__MODULE__, [type, gpio, name], name: name)
    struct = read(name)
    {:ok, pid, struct}
  end

  def start_link(type, gpio, name) do
    {:error, "the type must be either 11 or 22"}
  end


  def read(name) do
    GenServer.call(name, :read)
  end

  def set_temp(name, temp) when is_number(temp) do
    # convert temp to float with /1
    GenServer.call(name, {:set_temp, temp / 1})
  end

  def set(name, %Reading{} = reading)  do
    # convert temp to float with /1
    GenServer.call(name, {:set, reading})
  end


  # Server callbacks
  def init([type, gpio, name]) do
    reading = update(type, gpio)
    spawn_link(__MODULE__, :poll_temp, [self, type, gpio])
    struct = %Sensor.Temp{  module: __MODULE__, 
                            name: name, 
                            unit: reading.unit, 
                            value: reading.value,
                            status: reading.status
                          }
    {:ok, {type, gpio, struct}}
  end

  def handle_call(:read, _from, state = {_type, _gpio, struct}) do
    {:reply, struct, state}
  end

  def handle_call({:set_temp, temp}, _from, state = {type, gpio, reading}) do
    new_reading = %{reading | value: temp}
    {:reply, new_reading, {type, gpio, new_reading}}
  end

  def handle_call({:set, new_reading}, _from, state = {type, gpio, reading}) do
    {:reply, new_reading, {type, gpio, new_reading}}
  end

  defp update(_type, _gpio, tries \\ 0)
  defp update(_,_, tries) when tries > 4  do
    %Reading{status: :error}
  end

  defp update(type, gpio, tries) do
    result = @device.read(type, gpio)
    case result do
      {:ok, %{temp: temp}} ->
        %Reading{unit: "°C", value: temp, status: :ok}

      {:error, message} ->
        IO.puts message
        :timer.sleep 3000
        update(type, gpio, tries + 1)
    end
  end

  def poll_temp(client, type, gpio) do
    __MODULE__.set(client, update(type, gpio))
    :timer.sleep 5000
    poll_temp(client, type, gpio)
  end

end

defimpl TempSensor, for: Sensor.Temp.Dht do
  def sense(name) do
      GenServer.call(name, :read)
  end  
end