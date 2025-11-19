#!/bin/bash
# ============================================================================
# VERILOG SIMULATION SCRIPT - Using Icarus Verilog (Open Source)
# ============================================================================

echo "================================"
echo "Compiling Verilog..."
echo "================================"

# Compile Verilog files
iverilog -o pipeline_sim PipelineProcessor.v testbench.sv

if [ $? -ne 0 ]; then
    echo "Compilation failed!"
    exit 1
fi

echo "✓ Compilation successful"
echo ""

echo "================================"
echo "Running Simulation..."
echo "================================"

# Run simulation and generate VCD file
vvp pipeline_sim

echo ""
echo "================================"
echo "Simulation Complete"
echo "================================"
echo ""
echo "To view waveforms:"
echo "  gtkwave pipeline_simulation.vcd &"
echo ""
