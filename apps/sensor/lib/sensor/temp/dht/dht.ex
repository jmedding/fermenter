defmodule Sensor.Temp.Dht do
@moduledoc """
Get temperature values using the DHT family of sensors

This is implemented with the Adafruit_DHT library and will work for Rpi and Rpi2

It can be initialize with three parameters, (DhtType, pin, name) where name is an atom

The sensor will be polled at 5 second intervals. Calling the read function will
return the last reading, without waiting for a new read. This is because the 
reading process is somewhat slow, especially if the sensor returns an error, in which
case, it will pause and then try again.
"""
  
  @behaviour Sensor.Temp
  use GenServer

   @device Application.get_env(:sensor, :sensor_temp_dht)

  ## API callbacks

  @doc """
  Starts the DHT temp sensor server.
  type is to identify which type of DHT (11 | 22)
  gpio is the gpio number the sensor is attached to (ex: 4)
  """

  @spec start_link(Integer, Integer, :atom) :: {atom, pid}
  def start_link(type, gpio, name) when is_atom(name) and type in [11, 22] do
    #IO.puts "starting " <>  to_string(name)
    GenServer.start_link(__MODULE__, [type, gpio], name: name) 
  end

  def start_link(_type, _gpio, _name) do
    {:error, "the type must be either 11 or 22"}
  end

  @doc """
  Returns the most recent valid reading
  """

  @spec read(:atom) :: %Sensor.Temp{}
  def read(name) do
    GenServer.call(name, :read)
  end

  @doc """
  Will set the temperature value - only used during tests.
  """
  def set_temp(name, temp) when is_number(temp) do
    # convert temp to float with /1
    GenServer.call(name, {:set_temp, temp / 1})
  end

  @doc """
  Will update the state with a new reading
  """
  def set(name, %Sensor.Temp{} = reading)  do
    # convert temp to float with /1
    GenServer.call(name, {:set, reading})
  end


  # Server callbacks
  def init([type, gpio]) do
    reading = read_dht(type, gpio)
    spawn_link(__MODULE__, :poll_temp, [self, type, gpio])
    struct = %Sensor.Temp{  unit: reading.unit, 
                            value: reading.value,
                            status: reading.status
                          }
    {:ok, {type, gpio, struct}}
  end

  def handle_call(:read, _from, state = {_type, _gpio, struct}) do
    {:reply, struct, state}
  end

  def handle_call({:set_temp, temp}, _from, _state = {type, gpio, temp_struct}) do
    new_struct = %Sensor.Temp{temp_struct | value: temp}
    {:reply, :ok, {type, gpio, new_struct}}
  end

  def handle_call({:set, reading}, _from, _state = {type, gpio, _temp_struct}) do
    # TODO: add validation of new reading
    {:reply, :ok, {type, gpio, reading}}
  end

  
  # The read_dht function will try to get a reading from the physical sensor
  # The DHT communication protocal on the Rpi is a bit sketch, so 
  # It will make multiple requests until it gets a valid result.
  # The DHT needs a few seconds between requests, hence the 3s pause between tries
  # It returns a %Sensor.Temp struct and it is up to the caller to do something with the data

  defp read_dht(_type, _gpio, tries \\ 0)
  defp read_dht(_,_, tries) when tries > 4  do
    %Sensor.Temp{status: :error}
  end

  defp read_dht(type, gpio, tries) do
    result = @device.read(type, gpio)
    case result do
      {:ok, %{temp: temp}} ->
        %Sensor.Temp{unit: "°C", value: temp, status: :ok}

      {:error, message} ->
        IO.puts message
        :timer.sleep 3000
        read_dht(type, gpio, tries + 1)
    end
  end

  @doc """
  Spawned by the init function in a seperate process,
  it will request a new reading every 5 seconds.
  Please note that the reading process my run for many seconds
  if there are read failures, so the set function is NOT guaranteed 
  to run every 5 seconds.
  """
  def poll_temp(client, type, gpio) do
    __MODULE__.set(client, read_dht(type, gpio))
    :timer.sleep 5000
    poll_temp(client, type, gpio)
  end

end