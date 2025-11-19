// ============================================================================
// TESTBENCH: 5-Stage Pipelined RISC Processor
// ============================================================================

`timescale 1ns/1ps

module testbench;
    reg clk;
    reg reset;

    // Instantiate processor
    PipelineProcessor processor (
        .clk(clk),
        .reset(reset)
    );

    // ===== Clock Generation =====
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 10ns clock period (100 MHz)
    end

    // ===== Simulation Control =====
    initial begin
        // Enable waveform dumping for GTKWave or ModelSim
        $dumpfile("pipeline_simulation.vcd");
        $dumpvars(0, testbench);

        // Reset processor
        reset = 1'b1;
        #10;
        reset = 1'b0;

        // Run simulation for 200 cycles (to see stalls, forwarding, etc.)
        #2000;

        // Print results
        $display("\n========================================");
        $display("SIMULATION COMPLETE");
        $display("========================================\n");

        // Display final register values
        $display("Final Register Values:");
        $display("R1  = %h", processor.RegFile[1]);
        $display("R2  = %h", processor.RegFile[2]);
        $display("R3  = %h", processor.RegFile[3]);
        $display("R4  = %h", processor.RegFile[4]);
        $display("R5  = %h", processor.RegFile[5]);
        $display("R6  = %h", processor.RegFile[6]);
        $display("R7  = %h", processor.RegFile[7]);
        $display("R8  = %h", processor.RegFile[8]);
        $display("R9  = %h", processor.RegFile[9]);
        $display("R10 = %h", processor.RegFile[10]);
        $display("R11 = %h", processor.RegFile[11]);
        $display("R12 = %h", processor.RegFile[12]);

        $display("\nFinal Data Memory Values:");
        $display("Mem[0] = %h", processor.DataMem[0]);
        $display("Mem[1] = %h", processor.DataMem[1]);

        $finish;
    end

    // ===== Per-Cycle Monitoring =====
    integer cycle_count = 0;

    always @(posedge clk) begin
        cycle_count = cycle_count + 1;

        // Print pipeline state every cycle
        if (cycle_count > 1 && cycle_count < 20) begin  // First 20 cycles
            $display("\nCycle %0d:", cycle_count);
            $display("  PC = %h", processor.PC);
            $display("  Stall = %b", processor.Stall);
            $display("  IF/ID.Inst = %h", processor.IFID_Instruction);
            $display("  ID/EX.Rd = %0d", processor.IDEX_Rd);
            $display("  EX/MEM.ALUResult = %h", processor.EXMEM_ALUResult);
            $display("  MEM/WB.Rd = %0d", processor.MEMWB_Rd);
            $display("  ForwardA = %b, ForwardB = %b", processor.ForwardA, processor.ForwardB);
        end
    end

endmodule
