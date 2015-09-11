defmodule SimpleNeuron do
  use GenServer
  require Logger

  defstruct from_conns: [], to_conns: []

  def start_link() do
    GenServer.start_link(SimpleNeuron, %SimpleNeuron{})
  end

  def connect(neuron, to_neuron) do
    {GenServer.call(neuron, {:connect, to_neuron}), 
     GenServer.call(to_neuron, {:connected, neuron})}
  end

  def signal(neuron, value) do
    GenServer.cast(neuron, {:signal, value}) 
  end
  
  def forward_signal(%SimpleNeuron{to_conns: to_conns}, value) do
    for conn <- to_conns, do: signal(conn, value)
  end

  # Callbacks

  def handle_call({:connect, to_neuron}, from, %SimpleNeuron{to_conns: to_conns} = neuron) do
    {:reply, from, %SimpleNeuron{neuron|to_conns: [to_neuron|to_conns]}}
  end

  def handle_call({:connected, from_neuron}, from, %SimpleNeuron{from_conns: from_conns} = neuron) do
    {:reply, from, %SimpleNeuron{neuron|from_conns: [from_neuron|from_conns] }}
  end  

  def handle_cast({:signal, value}, %SimpleNeuron{} = neuron) do
    Logger.info("Received signal #{value}")
    forward_signal(neuron, value)
    {:noreply, neuron} 
  end

end

