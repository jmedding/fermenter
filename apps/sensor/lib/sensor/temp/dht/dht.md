# DHT Sensor setup

There are many libraries with information on reading the DHT11 and DHT22 temperature
and humidity sensors from the Raspberry Pi.  This library uses the Adafruit python 
library. 

[https://github.com/adafruit/Adafruit_Python_DHT]

Please follow the instructions to download and install the library.  A reasonable place is in the /home/pi directory.  Copy the DHT.py example from the library into 
the top-level bin directory.

More information about the DHT sensors and their underlying *single wire protocal* can
be found [here](http://www.uugear.com/portfolio/dht11-humidity-temperature-sensor-module/)

Pull request that use a c or c++ library that can be compiled by elixir_make 
are welcome!