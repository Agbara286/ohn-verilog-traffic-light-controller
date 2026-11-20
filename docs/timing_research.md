# Task 1 Research:Digital Clocks & Counter-Based Timing Mechanisms

## 1. What is a Digital Clock, and Why is it Required in Sequential Circuits?

A **digital clock** is a continuous, periodic square-wave signal that alternates between a logic LOW (`0`) and logic HIGH (`1`) at a fixed frequency ($f$). The time it takes to complete one full cycle is the **clock period** ($T = \frac{1}{f}$).

In **sequential circuits** (circuits whose outputs depend on both current inputs and previous states, such as Finite State Machines and counters), a clock is essential for three reasons:
* **Synchronization:** It acts as a global metronome, ensuring all flip-flops and registers update their stored values at the exact same instant (typically on the rising edge, `posedge clk`, or falling edge, `negedge clk`).
* **Preventing Race Conditions:** Without a clock, signals traveling through different combinational logic paths arrive at different times (propagation delay), causing unpredictable glitches and race conditions. A clock forces the circuit to wait until all combinational signals have settled before sampling the next state.
* **Deterministic State Progression:** It guarantees that an FSM moves from one state to the next in a controlled, predictable sequence rather than oscillating uncontrollably.

---

## 2. How Can a Counter Be Used to Measure Time in a Digital System?

Digital hardware has no built-in concept of "seconds" or "milliseconds"—it only sees clock edges. Because the clock period ($T$) is constant and known, a **digital counter** (a sequential circuit made of flip-flops that increments on every clock edge) can measure elapsed time by counting how many clock cycles have passed.

The relationship between elapsed time, clock frequency, and the required number of clock cycles is:

$$\text{Number of Clock Cycles} = \text{Desired Time (s)} \times \text{Clock Frequency (Hz)}$$

### Applying This to the Traffic Light Controller
* **Real-World FPGA Hardware (e.g., 50 MHz Clock):** One second equals $50,000,000$ clock cycles. A **clock divider** (a large counter) counts from `0` to `49,999,999` and outputs a single 1-cycle pulse (`tick`) every 1 second. A secondary state timer then counts those 1-second ticks (`10` for Green, `3` for Yellow).
* **Verilog Simulation (Scaled 1 Hz Clock):** Simulating 50 million cycles per second in a testbench is computationally slow and produces unreadable waveforms. Instead, we drive the testbench with a **1 Hz logical clock** (1 clock cycle = 1 second).
  * **10-second Green state:** Counter counts `10` clock cycles (`0` to `9`).
  * **3-second Yellow state:** Counter counts `3` clock cycles (`0` to `2`).
  * Once the counter reaches the target threshold for the current state, it signals the FSM to transition to the next state and resets the counter back to `0`.

---

## 3. Technical References
1. **Nandland** – *What is a Clock in an FPGA? / State Machines in Verilog*: [https://nandland.com/](https://nandland.com/)
2. **HDLBits** – *Sequential Logic & Counters Practice*: [https://hdlbits.01xz.net/wiki/Main_Page](https://hdlbits.01xz.net/wiki/Main_Page)
3. **Harris, D. M., & Harris, S. L. (2012).** *Digital Design and Computer Architecture* (2nd ed.). Morgan Kaufmann. (Chapter 3: Sequential Logic Design).
4. **All About Circuits** – *Digital Counters and Timing Circuits*: [https://www.allaboutcircuits.com/textbook/digital/](https://www.allaboutcircuits.com/textbook/digital/)