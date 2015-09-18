defmodule Nnex do
  
  def example do
    # Create our neurons
    {:ok, n1} = SimpleNeuron.start_link()
    {:ok, n2} = SimpleNeuron.start_link()
    {:ok, n3} = SimpleNeuron.start_link()
    {:ok, n4} = SimpleNeuron.start_link([bias: 0.13])
    # Create the synaptic connections
    SimpleNeuron.connect(n1, n4, 0.01)
    SimpleNeuron.connect(n2, n4, 0.05)
    SimpleNeuron.connect(n3, n4, 0.09)
    # Trigger input neurons
    SimpleNeuron.signal(n1, 1)
    SimpleNeuron.signal(n2, 2)
    SimpleNeuron.signal(n3, 3)
  end

end
