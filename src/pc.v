module PC_Module(clk, rst, PC, PC_Next);
    input clk, rst;
    input [31:0] PC_Next;
    output reg [31:0] PC;
    always @(posedge clk or negedge rst) PC <= !rst ? 0 : PC_Next;
endmodule