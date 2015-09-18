defmodule SimpleNeuron do
  use GenServer
  require Logger

  defstruct bias: 0, from_conns: [], to_conns: [], input_signals: []

  def start_link() do
    GenServer.start_link(SimpleNeuron, %SimpleNeuron{})
  end

  def start_link(args) do
    bias = args[:bias]
    Logger.debug("Creating node with bias: #{bias}")
    GenServer.start_link(SimpleNeuron, %SimpleNeuron{bias: bias})
  end

  def connect(neuron, to_neuron, weight) do
    {GenServer.call(neuron, {:connect, to_neuron}), 
     GenServer.call(to_neuron, {:connected, neuron, weight})}
  end

  def signal(neuron, value) do
    GenServer.cast(neuron, {:signal, value, self()}) 
  end
  
  defp forward_signal(%SimpleNeuron{to_conns: to_conns}, value) do 
    Logger.info("#{key(self())} sending value #{value} to #{:io_lib.format("~p", [to_conns])}")
    for conn <- to_conns, do: signal(conn, value)
  end

  # Callbacks

  def handle_call({:connect, to_neuron}, from, %SimpleNeuron{to_conns: to_conns} = neuron) do
    {:reply, from, %SimpleNeuron{neuron|to_conns: [to_neuron|to_conns]}}
  end

  def handle_call({:connected, from_neuron, weight}, from, %SimpleNeuron{from_conns: from_conns} = neuron) do
    {:reply, from, %SimpleNeuron{neuron|from_conns: [{key(from_neuron), weight}|from_conns] }}
  end  

 def handle_cast({:signal, value, from}, %SimpleNeuron{from_conns: from_conns} = neuron) when length(from_conns) == 0 do
    weight = from_conns[key(from)] 
    log_signal(value, from, weight)

    forward_signal(neuron, value)
    
    {:noreply, %{neuron|input_signals: []}} 
  end

  def handle_cast({:signal, value, from}, %SimpleNeuron{bias: bias, from_conns: from_conns, input_signals: input_signals} = neuron) 
    when length(from_conns) == (length(input_signals)+1) do
      weight = from_conns[key(from)]
      log_signal(value, from, weight)

      Logger.info("#{key(self())} ACTIVATED!")
      
      input_signals =  [{key(from), value}|input_signals]
      new_value = activation_function(from_conns, input_signals, bias)
      forward_signal(neuron, new_value)

      {:noreply, %{neuron|input_signals: []}} 
  end

  def handle_cast({:signal, value, from}, %SimpleNeuron{from_conns: from_conns, input_signals: input_signals} = neuron) do
    weight = from_conns[key(from)] 
    log_signal(value, from, weight)
    
    input_signals =  [{key(from), value}|input_signals]
    
    {:noreply, %{neuron|input_signals: input_signals}} 
  end

  # Helpers
  
  defp activation_function(from_conns, input_signals, bias) do
    pre_activation_function(from_conns, input_signals, bias) 
    |> :math.tanh
  end

  defp pre_activation_function(from_conns, input_signals, bias) do
    from_conns 
    |> Enum.map(fn({key, weight}) -> apply_weight(weight, input_signals[key]) end)
    |> apply_bias(bias)
    |> Enum.sum
  end

  defp apply_bias(values, bias) do
    [apply_weight(1, bias) | values]
  end

  defp apply_weight(weight, value) do
    Logger.info("Apply weight: #{weight} to value: #{value}")
    weight * value
  end

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
