# Design: System I/O, Operation & Timing Mechanism

## 1. System Operational Description
The Digital Traffic Light Controller regulates vehicle flow at a two-road intersection (**Road A** and **Road B**) using a synchronous Finite State Machine (FSM). 

On system startup or whenever the reset signal (`rst`) is asserted, the controller initializes to **State 1** (Road A: Green, Road B: Red) and resets the internal timer to `0`. On every rising edge of the clock (`clk`), an internal counter increments to track the duration of the active state:
1. **State 1 (10s):** Road A is **Green**, Road B is **Red**.
2. **State 2 (3s):** Road A transitions to **Yellow** (warning phase), Road B remains **Red**.
3. **State 3 (10s):** Road A transitions to **Red**, Road B becomes **Green**.
4. **State 4 (3s):** Road A remains **Red**, Road B transitions to **Yellow**.

After State 4 completes, the controller automatically loops back to State 1 and repeats continuously. At no point are both roads permitted to display Green simultaneously, and every Green-to-Red transition is strictly buffered by a 3-second Yellow phase.

---

## 2. System Inputs and Outputs

| Signal Name | Direction | Bit Width | Description |
| :--- | :--- | :--- | :--- |
| `clk` | Input | 1-bit | System clock signal (1 Hz logical clock for simulation; 1 cycle = 1 second). |
| `rst` | Input | 1-bit | Active-high synchronous reset. Resets FSM to State 1 and clears the counter. |
| `road_a` | Output | 3-bit (`[2:0]`) | Traffic light output for Road A (`[2]=Red`, `[1]=Yellow`, `[0]=Green`). |
| `road_b` | Output | 3-bit (`[2:0]`) | Traffic light output for Road B (`[2]=Red`, `[1]=Yellow`, `[0]=Green`). |

### Signal Encoding (One-Hot Output)
Each 3-bit road output uses one-hot encoding so only one light can be active per road at any time:
* `3'b100` = **Red**
* `3'b010` = **Yellow**
* `3'b001` = **Green**

---

## 3. Counter & Timing Mechanism
The controller uses a **4-bit synchronous up-counter** (`reg [3:0] timer`) to measure state durations.

* **Why 4 bits?** The longest state duration is 10 clock cycles. A 4-bit register can count from `0` to `15` ($2^4 - 1$), which easily accommodates a count of `10` without overflowing.
* **Counting Logic (Zero-Indexed):**
  * **10-Second States (States 1 & 3):** The counter starts at `0` and increments on each rising clock edge. When `timer == 4'd9` (meaning 10 full clock cycles have elapsed: `0, 1, 2, ..., 9`), the FSM advances to the next state and resets `timer` to `0`.
  * **3-Second States (States 2 & 4):** The counter starts at `0` and increments on each rising clock edge. When `timer == 4'd2` (meaning 3 full clock cycles have elapsed: `0, 1, 2`), the FSM advances to the next state and resets `timer` to `0`.
* **Total Cycle Period:** $10 + 3 + 10 + 3 = 26\text{ seconds}$ (26 clock cycles) per complete intersection cycle.