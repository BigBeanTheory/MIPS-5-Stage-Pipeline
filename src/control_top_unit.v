module Control_Unit_Top(Op, RegWrite, ImmSrc, ALUSrc, MemWrite, ResultSrc, Branch, funct3, funct7, ALUControl);
    input [6:0] Op, funct7;
    input [2:0] funct3;
    output RegWrite, ALUSrc, MemWrite, ResultSrc, Branch;
    output [1:0] ImmSrc;
    output [2:0] ALUControl;
    assign RegWrite = (Op == 7'b0110011 || Op == 7'b0000011 || Op == 7'b0010011);
    assign MemWrite = (Op == 7'b0100011);
    assign ResultSrc = (Op == 7'b0000011);
    assign ALUSrc = (Op == 7'b0000011 || Op == 7'b0100011 || Op == 7'b0010011);
    assign Branch = (Op == 7'b1100011);
    assign ImmSrc = (Op == 7'b0100011) ? 2'b01 : (Op == 7'b1100011) ? 2'b10 : 2'b00;
    assign ALUControl = (Op == 7'b0000011 || Op == 7'b0100011) ? 3'b000 :
                        (Op == 7'b1100011) ? 3'b001 :
                        (funct3 == 3'b000 && funct7 == 7'b0100000) ? 3'b001 :
                        (funct3 == 3'b000) ? 3'b000 :
                        (funct3 == 3'b111) ? 3'b011 :
                        (funct3 == 3'b110) ? 3'b010 :
                        (funct3 == 3'b010) ? 3'b101 : 3'b000;
endmodule