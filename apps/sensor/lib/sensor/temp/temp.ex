defmodule Sensor.Temp do
  @callback read(atom) :: %Sensor.Temp{}

  @supervisor SensorSupervisor

  defstruct unit: "°C",
            value: -99.9,
            status: :init
  
  @doc """
  Will first regesiter the name and fail if it is already registered
  Will then attempt to start the supervised sensr process
  If this fails, it will unregister the name and sent the errr message
  """
  def start(module, params, name) do
    Supervisor.start_child(@supervisor, build_spec(module, params, name)) 
  end

  @doc """
  Generic sense commard for any type of sensor that follows this patter
  TODO: think about how  protocal could be used to enforce this pattern
  """
  def sense(name) do
    case retrieve_module(name) do
      {:error, msg}-> {:error, msg}
      module -> module.read(name)
    end
  end

  defp build_spec(module, params, name) do
    count = Supervisor.count_children(@supervisor)
    id = to_string(module) <> "_" <> to_string(count.workers)
    Supervisor.Spec.worker(module, params ++ [name], id: id)
  end

  defp retrieve_module(name) do
    case Process.whereis(name) do
      nil -> {:error, "This process does not exist"}
      _ ->  {_,_,_,[list|_]} = :sys.get_status(name)
            [a | _] = list
            {_,{mod, _, _}} = a 
            mod
    end
  end
end
