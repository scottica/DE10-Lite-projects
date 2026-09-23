# DE10-Lite Digital Design Projects

SystemVerilog projects built for the Intel DE10-Lite FPGA as part of UBC digital design coursework, progressing from basic logic to state machines and a processor datapath.

| Project | What it demonstrates |
|---|---|
| **Combination Lock** | 6-digit keypad lock with three cooperating FSMs (20-state keypad scanner, 15-state digit tracker, lock controller), two-flop input synchronizers, and debouncing |
| **8-bit Processor Datapath** | ALU with 6 condition flags, dual-read register file, 128 bytes of RAM, and memory-mapped output to 7-segment displays |
| **Simple Combination Lock using FSM** | The same safe controller implemented both as a behavioral FSM and as hand-derived gate-level next-state logic |
| **7-Segment Display and Registers** | 4-bit adder with registered inputs, a 7-segment decoder, and a self-checking testbench driven by test-vector files |
| **Up and Down Counter using FSM** | Counter implemented as a state machine |
| **FSM** | Introductory state machine design |
| **Full Adder** | Combinational logic fundamentals |

**Tools:** SystemVerilog, Intel Quartus, DE10-Lite (MAX 10)

Related: [FPGA TRON Game](https://github.com/scottica/Tron-Game-), a bare-metal C game on the Nios V RISC-V soft processor.
