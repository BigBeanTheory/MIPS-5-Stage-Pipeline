`timescale 1ns/1ps
module tb;
    reg clk = 0, rst = 0;
    pipeline_top cpu (.clk(clk), .rst(rst));
    always #5 clk = ~clk;
    initial begin
        $dumpfile("pipeline.vcd");
        $dumpvars(0, tb);
        #10 rst = 1;
        #300 $finish;
    end
endmodule