# Sensor


Due to the small size and footprint of the the BEAM, Elixir is very well suited for
use in embedded applications.  The Nerves project is a great source for getting started.

Embedded applications will often need to interact with hardware sensors that are part of the
embedded device. These device are not always reliable so error conditions should be managed.
Also, during prototyping, it is common to switch hardware components, so it would be nice if you 
don't need to change your business logic if you want to try a different temperature sensor.

This is an application to abstract the usage of physical sensors on a Raspberry Pi or similar.
The main Sensor module is responsible for supervising the application.  Additionally, there are
modules for sensor types.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `sensor` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:sensor, "~> 0.1.0"}]
    end
    ```

  2. Ensure `sensor` is started before your application:

    ```elixir
    def application do
      [applications: [:sensor]]
    end
    ```


## Usage

The top-level `Sensor` module is the application supervisor and should be started automatically, as per above.  Sensor Types can be implmented as sub-modules and sensors are sub-sub modules.  The SensorTypes define a common data struct and behaviour to be implemented by the sensor modules of that type. This means your business logic only needs to know that you are using a Temperature sensor, but you don't have to care which type. If you want to change your hardware, you can just select a diffent sensor module, without making any changes to your business logic.

For example

```
iex > sensor_module = Sensor.Temp.Dht
iex > sensor_params = [11, 4]  #[Dht_type, gpio]
iex > name = :temp1 
iex > Sensor.Temp.start(sensor_module, sensor_params, name)
iex > Sensor.Temp.sense(name)
%Sensor.Temp{status: :ok, unit: "°C", value: 20.0}

```


## Under the hood

For example the Sensor.Temp module represents all temperature sensors. It defines a struct that each specific instance of a temperature sensor should use to report it's state as well as a behaviour to enforce this.  

```elixir
defmodule Sensor.Temp do
  @callback read(atom) :: %Sensor.Temp{}

  @supervisor SensorSupervisor

  defstruct unit: "°C",
            value: -99.9,
            status: :init
  
  ...

end
```

For example, the Sensor.Temp.Dht module, which can interact with a DHT temperature sensor, implments the Sensor.Temp behaviour:

 ```elixir
defmodule Sensor.Temp.Dht do
  
  @behaviour Sensor.Temp
  use GenServer

  @doc """
  Returns the most recent valid reading
  """

  @spec read(:atom) :: %Sensor.Temp{}
  def read(name) do
    GenServer.call(name, :read)
  end

  ...

end
 ```




