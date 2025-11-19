module Register_File(clk, rst, WE3, A1, A2, A3, WD3, RD1, RD2);
    input clk, rst, WE3;
    input [4:0] A1, A2, A3;
    input [31:0] WD3;
    output [31:0] RD1, RD2;
    reg [31:0] registers [31:0];
    integer i;
    always @(posedge clk or negedge rst) begin
        if (!rst) for (i = 0; i < 32; i = i + 1) registers[i] <= 0;
        else if (WE3) registers[A3] <= WD3;
    end
    assign RD1 = (A1 == 0) ? 0 : registers[A1];
    assign RD2 = (A2 == 0) ? 0 : registers[A2];
endmodule