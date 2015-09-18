NNex
====

A Neural Network prototype in Elixir (Under development)


Used as part of my [Transcendence in Erlang Talk](https://docs.google.com/presentation/d/1AGYBEL8Ng3VWc_WiHhjs4MrMFdn3gGsuNxYShS1BxL0/edit?usp=sharing), to demonstrate how Erlang processes can represent Neurons in an elegant way.

All Neurons (nodes) at present are ```GenServers``` with  ```SimpleNeuron``` struct state.

- Input Nodes: detected as they do not have any registered in connections therefore forward sensor input.
- Hidden Nodes: use hyperbolic tangent activation function + wait for 1 input from each in node before becoming activated.
- Output Nodes (not implemented): can be detected the same way as input neurons are, but will apply Softmax activation function.

## Example

Simple Feed Forward Demo:

``` elixir
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
```

``` shell
$ iex -S mix 

ex(1)> Nnex.example

13:41:07.418 [debug] Creating node with bias: 0.13

13:41:07.418 [info]  <0.91.0> Received signal 1 from <0.89.0> input sensor

13:41:07.421 [info]  <0.92.0> Received signal 2 from <0.89.0> input sensor

13:41:07.426 [info]  <0.93.0> Received signal 3 from <0.89.0> input sensor

13:41:07.426 [info]  <0.91.0> sending value 1 to [<0.94.0>]

13:41:07.430 [info]  <0.92.0> sending value 2 to [<0.94.0>]

13:41:07.430 [info]  <0.93.0> sending value 3 to [<0.94.0>]

13:41:07.430 [info]  <0.94.0> Received signal 1 from <0.91.0> with connection weight 0.01

13:41:07.430 [info]  <0.94.0> Received signal 2 from <0.92.0> with connection weight 0.05

13:41:07.430 [info]  <0.94.0> Received signal 3 from <0.93.0> with connection weight 0.09

13:41:07.430 [info]  <0.94.0> ACTIVATED!

13:41:07.430 [info]  Apply weight: 0.09 to value: 3

13:41:07.430 [info]  Apply weight: 0.05 to value: 2

13:41:07.430 [info]  Apply weight: 0.01 to value: 1

13:41:07.430 [info]  Apply weight: 1 to value: 0.13

13:41:07.431 [info]  <0.94.0> sending value 0.46994519893303766 to []
```

```0.46994519893303766``` represents the value node 4 computed from 3 input nodes.
