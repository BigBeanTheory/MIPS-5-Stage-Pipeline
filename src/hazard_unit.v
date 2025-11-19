module hazard_unit(rst, RegWriteM, RegWriteW, RD_M, RD_W, Rs1_E, Rs2_E, ForwardAE, ForwardBE);
    input rst, RegWriteM, RegWriteW;
    input [4:0] RD_M, RD_W, Rs1_E, Rs2_E;
    output [1:0] ForwardAE, ForwardBE;
    assign ForwardAE = rst ? 0 : (RegWriteM && RD_M != 0 && RD_M == Rs1_E) ? 2 : (RegWriteW && RD_W != 0 && RD_W == Rs1_E) ? 1 : 0;
    assign ForwardBE = rst ? 0 : (RegWriteM && RD_M != 0 && RD_M == Rs2_E) ? 2 : (RegWriteW && RD_W != 0 && RD_W == Rs2_E) ? 1 : 0;
endmodule