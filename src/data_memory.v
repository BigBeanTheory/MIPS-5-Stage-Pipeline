module Data_Memory(clk, rst, WE, WD, A, RD);
    input clk, rst, WE;
    input [31:0] A, WD;
    output [31:0] RD;
    reg [31:0] mem [1023:0];
    always @(posedge clk) if (WE) mem[A[11:2]] <= WD;
    assign RD = rst ? mem[A[11:2]] : 0;
    initial mem[0] = 0;
endmodule