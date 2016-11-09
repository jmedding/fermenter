# Sensor

Due to the small size and footprint of the the BEAM, Elixir is very well suited for
use in embedded applications.  The Nerves project is a great source for getting started.

Embedded applications will often need to interact with hardware sensors that are part of the
embedded device. These device are not always reliable so error conditions should be managed.
Also, during prototyping, it is common to switch hardware components, so it would be nice if you 
don't need to change your business logic if you want to try a different temperature sensor.

This is an application to abstract the usage of physical sensors on a Raspberry Pi or similar.
The main Sensor module is responsible for supervising the application.  Additionally, there are
modules for sensor types.  For example the Sensor.Temp module represents all temperature sensors.

It defines a struct that each specific instance of a temperature sensor should use to report it's state.
For example, the Sensor.Temp.Dht module can be used to interact with a DHT temperature sensor.




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

