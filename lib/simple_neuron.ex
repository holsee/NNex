defmodule SimpleNeuron do
  use GenServer
  require Logger

  defstruct from_conns: [], to_conns: [], input_signals: []

  def start_link() do
    GenServer.start_link(SimpleNeuron, %SimpleNeuron{})
  end

  def connect(neuron, to_neuron, weight) do
    {GenServer.call(neuron, {:connect, to_neuron}), 
     GenServer.call(to_neuron, {:connected, neuron, weight})}
  end

  def signal(neuron, value) do
    GenServer.cast(neuron, {:signal, value, self()}) 
  end
  
  defp forward_signal(%SimpleNeuron{to_conns: to_conns, input_signals: input_signals}, value) do 
    #if Enum.count(to_conns) == Enum.count(input_signals) do 
      for conn <- to_conns, do: signal(conn, value)
    # end
  end

  # Callbacks

  def handle_call({:connect, to_neuron}, from, %SimpleNeuron{to_conns: to_conns} = neuron) do
    {:reply, from, %SimpleNeuron{neuron|to_conns: [to_neuron|to_conns]}}
  end

  def handle_call({:connected, from_neuron, weight}, from, %SimpleNeuron{from_conns: from_conns} = neuron) do
    {:reply, from, %SimpleNeuron{neuron|from_conns: [{key(from_neuron), weight}|from_conns] }}
  end  

  def handle_cast({:signal, value, from}, %SimpleNeuron{from_conns: from_conns, input_signals: input_signals} = neuron) do
    
    weight = from_conns[key(from)] 

    log_signal(value, from, weight)
  
    # TODO: perform computation when all inputs have arrived and then forward signal    
    forward_signal(neuron, value)
    
    {:noreply, %{neuron|input_signals: [{value, from}|input_signals]}} 
  end

  # Helpers

  defp key(pid) when is_pid(pid) do
    pid 
    |> :erlang.pid_to_list
    |> :erlang.list_to_atom
  end
  
  defp log_signal(value, from, nil) do
    Logger.info("#{key(self())} Received signal #{value} from #{key(from)} input sensor")
  end
  defp log_signal(value, from, weight) do
    Logger.info("#{key(self())} Received signal #{value} from #{key(from)} with connection weight #{weight}")
  end
 
end

