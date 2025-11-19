#!/bin/bash
# ============================================================================
# VERILOG SYNTHESIS SCRIPT - Using Yosys (Open Source)
# ============================================================================

DESIGN="PipelineProcessor"

echo "================================"
echo "Synthesizing Verilog..."
echo "================================"

# Synthesis script for Yosys
cat > synth.ys << 'EOF'
read_verilog PipelineProcessor.v
hierarchy -check -top PipelineProcessor
proc
opt_clean -purge
show -format png -prefix pipeline_rtl
write_rtlil pipeline.rtl
write_verilog pipeline_synth.v
write_json pipeline.json
EOF

# Run Yosys
yosys synth.ys

echo "✓ Synthesis complete"
echo ""
echo "Generated files:"
echo "  - pipeline_synth.v (synthesized netlist)"
echo "  - pipeline.json (JSON representation)"
echo "  - pipeline_rtl.png (RTL diagram)"
echo ""
