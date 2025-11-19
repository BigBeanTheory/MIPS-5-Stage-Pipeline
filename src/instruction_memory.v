module Instruction_Memory(rst, A, RD);
    input rst;
    input [31:0] A;
    output [31:0] RD;
    reg [31:0] mem [1023:0];
    assign RD = rst ? mem[A[31:2]] : 0;
    initial $readmemh("memfile.hex", mem);
endmodule