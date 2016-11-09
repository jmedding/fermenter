# Sensor

Elixir is very well suited for use in embedded applications.  See the [Nerves project](http://nerves-project.org/) if you are interested to learn more about this.

Embedded applications often need to interact with hardware sensors that are attached to or part of the
embedded device. These devices often rely on OS and hardware specific drivers, which are usually not writen in Elixir and are not always reliable.

My goals for this project are to

1. Use OTP to reliably manage communication with these devices.
2. Provide abstract sensor types to be used in application business logic in such a way that nothing more than a configuration change would be needed to use a different sensor in your application
3. Make the app extensible, so that it can grow into a general repository of sensor implementations, used and supported by the Elixir community.
  
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

The top-level `Sensor` module is the application supervisor and should be started automatically, as per above.  Generic sensor types can be implmented as sub-modules. These modules should define a struct to hold the relevant sensor reading data and a behaviour that any specific instances of the generic type must implement.  The specific sensors types are sub-sub modules and should implement the generic type's behaviour.  With this design pattern, you can reference the generic type in your business logic but instantiate the actual process with a specific sub-module of that type.  As an example, your business logic only needs to know that you are using a temperature sensor (`Sensor.Temp`), but you don't have to care which type. If you want to change your hardware, you can just select a diffent temperature sensor module without making any changes to your business logic.

For example

```
iex > specific_sensor_module = Sensor.Temp.Dht
iex > sensor_params = [11, 4]  #[Dht_type, gpio]
iex > name = :temp1 
iex > Sensor.Temp.start(specific_sensor_module, sensor_params, name)
iex > Sensor.Temp.sense(name)
%Sensor.Temp{status: :ok, unit: "°C", value: 20.0}

iex > other_specific_sensor_module = Sensor.Temp.Other
iex > sensor_params = [5]  #[gpio]
iex > name2 = :temp2
iex > Sensor.Temp.start(other_specific_sensor_module, [gpio2], name2)
iex > Sensor.Temp.sense(name2)
%Sensor.Temp{status: :ok, unit: "°C", value: 20.0}
```


## Under the hood

So far, only the Temperature Sensor (`Sensor.Temp`) generic type is implemented, but we can use it as an example to see how the pattern works.  It defines a struct that each specific instance of a temperature sensor should use to report its state as well as a behaviour that the specific type modules must implement.  

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

The `Sensor.Temp.Dht module` is a specific type of temperature sensor which can interact with a DHT temperature sensor. This module implments the `Sensor.Temp` behaviour:

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
 
The user doesn't need to care how the module interacts with the sensor because all calls are made to the generic `Sensor.Temp` module, which abstracts them.

Please try to respect this pattern when implementing other Sensor Types.  I would be very happy to get a pull request if you do extend this application with other sensor types.



