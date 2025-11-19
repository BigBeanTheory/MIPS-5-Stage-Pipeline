# 5-Stage Pipelined MIPS Processor with Hazard Handling

This repository implements a synthesizable 5-stage pipelined MIPS processor in Verilog, featuring operand forwarding for data hazards and early branch resolution for control hazards. The design supports R-type (ADD, SUB, AND, OR, XOR), I-type (ADDI, ANDI, LW, SW), and branch (BEQ) instructions. Initially prototyped in Logisim for validation, then implemented in Verilog and verified with Icarus Verilog and GTKWave. Achieves CPI of 2.0 for short test programs (4 instructions) and approaches 1.0 for longer sequences, with zero stalls for resolved hazards. [file:1]

## Features
- **Pipeline Stages**: Instruction Fetch (IF), Decode (ID), Execute (EX), Memory (MEM), Write Back (WB) with inter-stage registers.
- **Hazard Resolution**: Forwarding from EX/MEM and MEM/WB stages eliminates RAW data hazards; static predict-not-taken for branches with 2-cycle mispredict penalty.
- **ALU**: 16 operations including arithmetic, logical, shifts (SLL, SRL, SRA), and comparisons (SLT, SLTU).
- **Memories**: Instruction ROM (64 entries) and Data RAM with load/store support.
- **Verification**: Logisim simulation for structural checks; Verilog testbench for functional and performance analysis (500ns runtime, 10ns clock).
- **Test Program**: 4-instruction sequence demonstrating ADD, SW, LW, BEQ with inherent hazards resolved via forwarding. [file:1]

## Architecture Overview
The processor follows the classic MIPS pipeline model:
- **IF**: PC increment and instruction fetch from IMEM.
- **ID**: Decode, register reads, sign-extend immediates; control signals generated.
- **EX**: ALU computation (with forwarding muxes), branch target/address evaluation.
- **MEM**: Data memory access for LW/SW.
- **WB**: Result write to register file (x0 hardwired to 0).

Data hazards are detected in the hazard unit and resolved by multiplexing ALU inputs from pipeline registers. Control hazards use PCSrcE for branch redirection in EX. For visuals, see `docs/design_diagram.png` and simulation traces in `docs/simulation_waveforms.png`. [file:1]

## Prerequisites
- Icarus Verilog (iverilog, vvp): For compilation and simulation.
- GTKWave: For waveform viewing.
- Logisim-Evolution: For prototyping (optional, Java-based).
- Bash environment for build script.

Install on Ubuntu/Debian: `sudo apt install iverilog gtkwave logisim-evolution`. [file:1]

## Setup and Usage
1. Clone the repo: `git clone <repo-url> && cd <repo-name>`.
2. Run simulation:
   - `./build.sh`: Compiles modules, runs testbench, generates `pipeline.vcd`.
   - Open waveforms: `gtkwave pipeline.vcd waves.gtkw` (views PC, instructions, ALU results, controls).
3. Prototype in Logisim: Open `logisim/mips_pipeline.circ` and simulate stages.
4. Analyze results: Check CPI (8 cycles for 4 instructions) and hazard-free execution in waveforms. No stalls for test program; branch not taken (PCSrcE=0). [file:1]

Expected output: ALUResultM=0xF (from ADD), memory store/load correct, BEQ skips to 0x10.

## Performance Analysis
- **CPI Calculation**: For N=4 instructions, total cycles=8 (pipeline fill/drain overhead), CPI=2.0. For N→∞, CPI≈1.0 (96.2% efficiency for N=100). [file:1]
- **Hazard Verification**: RAW hazards (e.g., SW after ADD) resolved by EX/MEM forwarding; LW-BEQ by MEM/WB. Load-use hazards would stall if present (not in test).
- **Limitations**: No dynamic branch prediction; assumes 32-bit MIPS subset. Extendable for full ISA or multi-cycle execution.

## Project Structure
- `src/`: Verilog modules (pipeline_top.v, alu.v, etc.).
- `sim/`: Testbench, memfile.hex, build.sh.
- `logisim/`: .circ files for prototyping.
- `docs/`: Report PDF, diagrams, waveforms.
- `report.pdf`: Full ENCA302 assignment report with methodology, results, and references. [file:1]

## Course Context
Developed for ENCA302: Introduction to Computer Organization and Architecture (KR Mangalam University, BCA Semester V). References: Patterson & Hennessy (5th ed.), MIPS ISA docs. [file:1]

## License
MIT License. Academic use encouraged; cite the report for derivatives.
