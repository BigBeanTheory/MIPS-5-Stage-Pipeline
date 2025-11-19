module ALU(A, B, Result, ALUControl, Zero);
    input [31:0] A, B;
    input [2:0] ALUControl;
    output [31:0] Result;
    output Zero;
    wire [31:0] sum = ALUControl[0] ? (A - B) : (A + B);
    assign Result = (ALUControl == 3'b000) ? sum :
                    (ALUControl == 3'b010) ? A & B :
                    (ALUControl == 3'b011) ? A | B :
                    (ALUControl == 3'b101) ? {{31{1'b0}}, sum[31]} : 0;
    assign Zero = ~|Result;
endmodule