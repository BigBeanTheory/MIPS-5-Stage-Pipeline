// ============================================================================
// 5-Stage Pipelined RISC Processor with Hazard Handling
// Assignment 3: Computer Organization & Architecture
// ============================================================================

// ============================================================================
// 1. MAIN PROCESSOR MODULE
// ============================================================================
module PipelineProcessor (
    input clk,
    input reset
);

    // ===== Pipeline Signals =====

    // IF/ID Pipeline Register
    reg [31:0] IFID_PC;
    reg [31:0] IFID_Instruction;

    // ID/EX Pipeline Register
    reg [31:0] IDEX_RegData1;
    reg [31:0] IDEX_RegData2;
    reg [31:0] IDEX_SignExtImm;
    reg [4:0]  IDEX_Rd;
    reg [4:0]  IDEX_Rs1;
    reg [4:0]  IDEX_Rs2;
    reg [2:0]  IDEX_ALUOp;
    reg        IDEX_RegWrite;
    reg        IDEX_MemRead;
    reg        IDEX_MemWrite;

    // EX/MEM Pipeline Register
    reg [31:0] EXMEM_ALUResult;
    reg [31:0] EXMEM_WriteData;
    reg [4:0]  EXMEM_Rd;
    reg        EXMEM_RegWrite;
    reg        EXMEM_MemRead;
    reg        EXMEM_MemWrite;

    // MEM/WB Pipeline Register
    reg [31:0] MEMWB_MemReadData;
    reg [31:0] MEMWB_ALUResult;
    reg [4:0]  MEMWB_Rd;
    reg        MEMWB_RegWrite;

    // ===== Control Signals =====
    wire [1:0] ForwardA, ForwardB;
    wire       Stall;
    wire       PCWrite;
    wire       IFIDWrite;

    // ===== Program Counter =====
    reg [31:0] PC;
    wire [31:0] PC_next;
    wire [31:0] PC_plus_4;

    // ===== Memories =====
    reg [31:0] InstMem [0:1023];  // Instruction Memory
    reg [31:0] DataMem [0:1023];  // Data Memory

    // ===== Register File =====
    reg [31:0] RegFile [0:31];

    // ===== Fetch Stage (IF) =====
    wire [31:0] Instruction;

    assign PC_plus_4 = PC + 32'd4;
    assign PC_next = Stall ? PC : PC_plus_4;
    assign Instruction = InstMem[PC[9:0]];

    always @(posedge clk or posedge reset) begin
        if (reset)
            PC <= 32'd0;
        else if (PCWrite)
            PC <= PC_next;
    end

    // ===== Decode Stage (ID) =====
    wire [6:0]  opcode = IFID_Instruction[6:0];
    wire [2:0]  funct3 = IFID_Instruction[14:12];
    wire [6:0]  funct7 = IFID_Instruction[31:25];
    wire [4:0]  rs1_addr = IFID_Instruction[19:15];
    wire [4:0]  rs2_addr = IFID_Instruction[24:20];
    wire [4:0]  rd_addr = IFID_Instruction[11:7];
    wire [31:0] imm_signed = {{20{IFID_Instruction[31]}}, IFID_Instruction[31:20]};

    wire [31:0] RegData1 = RegFile[rs1_addr];
    wire [31:0] RegData2 = RegFile[rs2_addr];

    wire RegWrite_ID, MemRead_ID, MemWrite_ID;
    wire [2:0] ALUOp_ID;

    ControlUnit control_unit (
        .opcode(opcode),
        .RegWrite(RegWrite_ID),
        .MemRead(MemRead_ID),
        .MemWrite(MemWrite_ID),
        .ALUOp(ALUOp_ID)
    );

    // ===== Execute Stage (EX) =====
    wire [31:0] ALUInputA, ALUInputB;
    wire [31:0] ALUResult;

    assign ALUInputA = (ForwardA == 2'b10) ? EXMEM_ALUResult :
                       (ForwardA == 2'b01) ? MEMWB_ALUResult :
                       IDEX_RegData1;

    assign ALUInputB = (ForwardB == 2'b10) ? EXMEM_ALUResult :
                       (ForwardB == 2'b01) ? MEMWB_ALUResult :
                       IDEX_RegData2;

    ALU alu (
        .InputA(ALUInputA),
        .InputB(ALUInputB),
        .ALUOp(IDEX_ALUOp),
        .Result(ALUResult)
    );

    // ===== Memory Stage (MEM) =====
    wire [31:0] MemReadData;

    assign MemReadData = DataMem[EXMEM_ALUResult[9:0]];

    always @(posedge clk) begin
        if (EXMEM_MemWrite)
            DataMem[EXMEM_ALUResult[9:0]] <= EXMEM_WriteData;
    end

    // ===== Write-Back Stage (WB) =====
    wire [31:0] WriteData;

    assign WriteData = MEMWB_RegWrite ? 
                      (MEMWB_MemReadData != 0 ? MEMWB_MemReadData : MEMWB_ALUResult) :
                      32'd0;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            RegFile[0] <= 32'd0;
            RegFile[1] <= 32'd0;
            RegFile[2] <= 32'd5;   // R2 = 5
            RegFile[3] <= 32'd3;   // R3 = 3
            RegFile[4] <= 32'd0;
            RegFile[5] <= 32'd2;   // R5 = 2
            RegFile[6] <= 32'd0;
            RegFile[7] <= 32'd1;   // R7 = 1
        end else if (MEMWB_RegWrite && MEMWB_Rd != 0) begin
            RegFile[MEMWB_Rd] <= WriteData;
        end
    end

    // ===== Hazard Detection Unit =====
    HazardDetectionUnit hazard_unit (
        .ID_EX_MemRead(IDEX_MemRead),
        .ID_EX_Rd(IDEX_Rd),
        .IF_ID_Rs1(rs1_addr),
        .IF_ID_Rs2(rs2_addr),
        .Stall(Stall),
        .PCWrite(PCWrite),
        .IFIDWrite(IFIDWrite)
    );

    // ===== Forwarding Unit =====
    ForwardingUnit forwarding_unit (
        .EX_MEM_RegWrite(EXMEM_RegWrite),
        .EX_MEM_Rd(EXMEM_Rd),
        .MEM_WB_RegWrite(MEMWB_RegWrite),
        .MEM_WB_Rd(MEMWB_Rd),
        .ID_EX_Rs1(IDEX_Rs1),
        .ID_EX_Rs2(IDEX_Rs2),
        .ForwardA(ForwardA),
        .ForwardB(ForwardB)
    );

    // ===== Pipeline Register Updates =====

    // IF/ID Register
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            IFID_PC <= 32'd0;
            IFID_Instruction <= 32'd0;
        end else if (IFIDWrite) begin
            IFID_PC <= PC;
            IFID_Instruction <= Instruction;
        end
    end

    // ID/EX Register
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            IDEX_RegData1 <= 32'd0;
            IDEX_RegData2 <= 32'd0;
            IDEX_SignExtImm <= 32'd0;
            IDEX_Rd <= 5'd0;
            IDEX_Rs1 <= 5'd0;
            IDEX_Rs2 <= 5'd0;
            IDEX_ALUOp <= 3'd0;
            IDEX_RegWrite <= 1'b0;
            IDEX_MemRead <= 1'b0;
            IDEX_MemWrite <= 1'b0;
        end else if (!Stall) begin
            IDEX_RegData1 <= RegData1;
            IDEX_RegData2 <= RegData2;
            IDEX_SignExtImm <= imm_signed;
            IDEX_Rd <= rd_addr;
            IDEX_Rs1 <= rs1_addr;
            IDEX_Rs2 <= rs2_addr;
            IDEX_ALUOp <= ALUOp_ID;
            IDEX_RegWrite <= RegWrite_ID;
            IDEX_MemRead <= MemRead_ID;
            IDEX_MemWrite <= MemWrite_ID;
        end else begin
            // Insert NOP (bubble) when stall occurs
            IDEX_RegWrite <= 1'b0;
            IDEX_MemRead <= 1'b0;
            IDEX_MemWrite <= 1'b0;
        end
    end

    // EX/MEM Register
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            EXMEM_ALUResult <= 32'd0;
            EXMEM_WriteData <= 32'd0;
            EXMEM_Rd <= 5'd0;
            EXMEM_RegWrite <= 1'b0;
            EXMEM_MemRead <= 1'b0;
            EXMEM_MemWrite <= 1'b0;
        end else begin
            EXMEM_ALUResult <= ALUResult;
            EXMEM_WriteData <= ALUInputB;
            EXMEM_Rd <= IDEX_Rd;
            EXMEM_RegWrite <= IDEX_RegWrite;
            EXMEM_MemRead <= IDEX_MemRead;
            EXMEM_MemWrite <= IDEX_MemWrite;
        end
    end

    // MEM/WB Register
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            MEMWB_MemReadData <= 32'd0;
            MEMWB_ALUResult <= 32'd0;
            MEMWB_Rd <= 5'd0;
            MEMWB_RegWrite <= 1'b0;
        end else begin
            MEMWB_MemReadData <= MemReadData;
            MEMWB_ALUResult <= EXMEM_ALUResult;
            MEMWB_Rd <= EXMEM_Rd;
            MEMWB_RegWrite <= EXMEM_RegWrite;
        end
    end

    // ===== Initialize Instruction Memory =====
    initial begin
        // Sample 10-instruction program
        InstMem[0]  = 32'h00a28533;  // ADD R1, R2, R3
        InstMem[1]  = 32'h40328733;  // SUB R4, R1, R5
        InstMem[2]  = 32'h00726833;  // AND R6, R1, R7
        InstMem[3]  = 32'h00428933;  // OR R8, R1, R4
        InstMem[4]  = 32'h00148483;  // LOAD R9, 0(R1)
        InstMem[5]  = 32'h00948533;  // ADD R10, R9, R2
        InstMem[6]  = 32'h00228063;  // BEQ R1, R2, 8
        InstMem[7]  = 32'h40318b33;  // SUB R11, R3, R4
        InstMem[8]  = 32'h00a52a23;  // STORE R10, 0(R2)
        InstMem[9]  = 32'h00858633;  // ADD R12, R11, R8
    end

    // ===== Initialize Data Memory =====
    initial begin
        DataMem[0] = 32'h00000010;  // Sample data at address 0
    end

endmodule

// ============================================================================
// 2. CONTROL UNIT
// ============================================================================
module ControlUnit (
    input [6:0] opcode,
    output reg RegWrite,
    output reg MemRead,
    output reg MemWrite,
    output reg [2:0] ALUOp
);

    always @(*) begin
        case (opcode)
            7'b0110011: begin  // R-type (ADD, SUB, AND, OR, XOR)
                RegWrite = 1'b1;
                MemRead = 1'b0;
                MemWrite = 1'b0;
                ALUOp = 3'b000;  // ADD by default
            end
            7'b0010011: begin  // I-type (ADDI, etc.)
                RegWrite = 1'b1;
                MemRead = 1'b0;
                MemWrite = 1'b0;
                ALUOp = 3'b000;  // ADD
            end
            7'b0000011: begin  // LOAD
                RegWrite = 1'b1;
                MemRead = 1'b1;
                MemWrite = 1'b0;
                ALUOp = 3'b000;  // ADD (for address)
            end
            7'b0100011: begin  // STORE
                RegWrite = 1'b0;
                MemRead = 1'b0;
                MemWrite = 1'b1;
                ALUOp = 3'b000;  // ADD (for address)
            end
            7'b1100011: begin  // BRANCH
                RegWrite = 1'b0;
                MemRead = 1'b0;
                MemWrite = 1'b0;
                ALUOp = 3'b001;  // SUB (for comparison)
            end
            default: begin
                RegWrite = 1'b0;
                MemRead = 1'b0;
                MemWrite = 1'b0;
                ALUOp = 3'b000;
            end
        endcase
    end

endmodule

// ============================================================================
// 3. ALU (Arithmetic Logic Unit)
// ============================================================================
module ALU (
    input [31:0] InputA,
    input [31:0] InputB,
    input [2:0]  ALUOp,
    output reg [31:0] Result
);

    always @(*) begin
        case (ALUOp)
            3'b000: Result = InputA + InputB;           // ADD
            3'b001: Result = InputA - InputB;           // SUB
            3'b010: Result = InputA & InputB;           // AND
            3'b011: Result = InputA | InputB;           // OR
            3'b100: Result = InputA ^ InputB;           // XOR
            3'b101: Result = InputA << InputB[4:0];     // SLL
            3'b110: Result = InputA >> InputB[4:0];     // SRL
            3'b111: Result = InputA ^ InputB;           // XOR (default)
            default: Result = 32'd0;
        endcase
    end

endmodule

// ============================================================================
// 4. HAZARD DETECTION UNIT
// ============================================================================
module HazardDetectionUnit (
    input        ID_EX_MemRead,
    input [4:0]  ID_EX_Rd,
    input [4:0]  IF_ID_Rs1,
    input [4:0]  IF_ID_Rs2,
    output reg   Stall,
    output wire  PCWrite,
    output wire  IFIDWrite
);

    always @(*) begin
        if (ID_EX_MemRead && ((ID_EX_Rd == IF_ID_Rs1) || (ID_EX_Rd == IF_ID_Rs2))) begin
            Stall = 1'b1;
        end else begin
            Stall = 1'b0;
        end
    end

    assign PCWrite = !Stall;
    assign IFIDWrite = !Stall;

endmodule

// ============================================================================
// 5. FORWARDING UNIT
// ============================================================================
module ForwardingUnit (
    input        EX_MEM_RegWrite,
    input [4:0]  EX_MEM_Rd,
    input        MEM_WB_RegWrite,
    input [4:0]  MEM_WB_Rd,
    input [4:0]  ID_EX_Rs1,
    input [4:0]  ID_EX_Rs2,
    output reg [1:0] ForwardA,
    output reg [1:0] ForwardB
);

    always @(*) begin
        // ForwardA logic for ALU operand A
        if (EX_MEM_RegWrite && (EX_MEM_Rd != 5'd0) && (EX_MEM_Rd == ID_EX_Rs1)) begin
            ForwardA = 2'b10;  // From EX/MEM
        end else if (MEM_WB_RegWrite && (MEM_WB_Rd != 5'd0) && (MEM_WB_Rd == ID_EX_Rs1)) begin
            ForwardA = 2'b01;  // From MEM/WB
        end else begin
            ForwardA = 2'b00;  // No forwarding
        end

        // ForwardB logic for ALU operand B
        if (EX_MEM_RegWrite && (EX_MEM_Rd != 5'd0) && (EX_MEM_Rd == ID_EX_Rs2)) begin
            ForwardB = 2'b10;  // From EX/MEM
        end else if (MEM_WB_RegWrite && (MEM_WB_Rd != 5'd0) && (MEM_WB_Rd == ID_EX_Rs2)) begin
            ForwardB = 2'b01;  // From MEM/WB
        end else begin
            ForwardB = 2'b00;  // No forwarding
        end
    end

endmodule
