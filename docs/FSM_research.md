1. Finite State Machine (FSM)
A Finite State Machine (FSM) is a sequential digital circuit, and also a computational model, that is in exactly one of a finite number of states at any given time. It moves between states in response to inputs (and, in hardware, a clock) and can produce outputs. FSMs are the standard way of describing and implementing control logic in digital systems such as traffic lights, sequence detectors, protocol controllers and vending machines.
Formally, an FSM is defined by a set of states, an input alphabet, an output alphabet, a next-state (transition) function, an output function and an initial state. In hardware, the current state is held in flip-flops, the next-state logic is combinational, and the outputs are produced by combinational logic that depends on the current state (and, for some machines, the current inputs).
2. States and State Transitions
•	States represent distinct conditions or modes of the system, for example “idle”, “waiting for coin”, “dispensing”, or the partial matches seen so far in a sequence detector. The current state is the machine’s memory of the relevant past inputs.
•	State transitions are the rules that determine the next state from the current state and the present inputs. They are drawn as directed arcs on a state diagram and tabulated in a state (next-state) table. On each active clock edge, the machine evaluates the transition function and updates the state register.
Because the number of states is finite, the complete behaviour of the machine can be specified exhaustively and verified systematically.
3. Differences Between Moore and Mealy Machines
Moore and Mealy machines are both FSMs. They differ only in how the output function is defined, as summarised in Table 1.
Table 1: Comparison of Moore and Mealy machines
Aspect	Moore Machine	Mealy Machine
Output depends on	Current state only	Current state and current inputs
Output notation	Written inside the state circles	Written on the transition arcs (input/output)
Typical number of states	Usually more	Usually fewer
Output timing	Changes only after a clock edge, together with the state	Can change as soon as an input changes, within the same cycle
Glitch / hazard risk	Low, since outputs follow the registered state	Higher, because of a combinational path from input to output
Response speed	One clock cycle later	Faster; same-cycle reaction is possible

Moore machines are preferred when clean, glitch-free, fully synchronous outputs are important. Mealy machines are preferred when a faster response or a smaller number of states is needed. The two models are computationally equivalent: any Mealy machine can be converted into a Moore machine, and vice versa, by adding states where necessary.
4. Implementing an FSM in Verilog
The recommended, synthesizable coding style separates the design into three pieces of logic (or two, if the outputs are merged with the next-state logic):
•	State register: a clocked always block that updates the current state on the active clock edge and handles reset.
•	Next-state logic: a combinational block (or continuous assignments) that computes the next state from the current state and the inputs, almost always using a case statement.
•	Output logic: combinational logic that produces the outputs. For a Moore machine it depends only on the state; for a Mealy machine it also depends on the inputs.
Key practical points include: using parameter or localparam for state encodings; always including a default case so that the machine recovers from illegal states; using non-blocking assignments (<=) in the sequential block and blocking assignments (=) in combinational blocks; and keeping the state register as simple as possible.
