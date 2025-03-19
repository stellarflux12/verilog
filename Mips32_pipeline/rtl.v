`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/16/2024 04:55:06 PM
// Design Name: 
// Module Name: MIPS32
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module mips32(clk1, clk2);
input clk1, clk2;

reg [31:0] PC, IF_ID_IR, IF_ID_NPC;
reg [31:0] ID_EX_IR, ID_EX_NPC, ID_EX_A, ID_EX_B, ID_EX_Imm;
reg [31:0] EX_MEM_IR, EX_MEM_B, EX_MEM_ALUo, EX_MEM_cond;
reg [31:0] MEM_WB_ALUo, MEM_WB_LMD, MEM_WB_IR;
reg [31:0] Reg[0:31];
reg [31:0] MEM[0:1023];
reg [2:0]  ID_EX_T, EX_MEM_T, MEM_WB_T;

parameter ADD = 6'd0, SUB = 6'd1, AND = 6'd2, OR = 6'd3, SLT = 6'd4, MUL = 6'd5, HLT = 6'b111111,
          LW = 6'd8, SW = 6'd9, ADDI = 6'd10, SUBI = 6'd11, SLTI = 6'd12, BNEQZ = 6'd13, BEQZ = 6'd14;
parameter  RR = 3'd0, RM = 3'd1, LOAD = 3'd2, STORE = 3'd3, B = 3'd4, H = 3'd5;

reg HA;
reg TAKEN_B;

always @(posedge clk1) begin
    if (HA == 0) begin
        if (((EX_MEM_IR[31:26] == BEQZ) && (EX_MEM_cond == 1)) || 
            ((EX_MEM_IR[31:26] == BNEQZ) && (EX_MEM_cond == 0))) begin
            IF_ID_IR <= #2 MEM[EX_MEM_ALUo];
            TAKEN_B <= #2 1'b1;
            IF_ID_NPC <= #2 EX_MEM_ALUo + 1;
            PC <= #2 EX_MEM_ALUo + 1;
        end else begin
            IF_ID_IR <= #2 MEM[PC];
            IF_ID_NPC <= #2 PC + 1;
            PC <= #2 PC + 1;
        end
    end
end

always @(posedge clk2) begin
    if (HA == 0) begin
        ID_EX_A <= #2 Reg[IF_ID_IR[25:21]];
        ID_EX_B <= #2 Reg[IF_ID_IR[20:16]];
        ID_EX_NPC <= #2 IF_ID_NPC;
        ID_EX_IR <= #2 IF_ID_IR;
        ID_EX_Imm <= #2 {{16{IF_ID_IR[15]}}, {IF_ID_IR[15:0]}};
        
        case (IF_ID_IR[31:26])
            ADD, SUB, MUL, AND, OR, SLT: ID_EX_T <= #2 RR;
            ADDI, SUBI, SLTI: ID_EX_T <= #2 RM;
            LW: ID_EX_T <= #2 LOAD;
            SW: ID_EX_T <= #2 STORE;
            BNEQZ, BEQZ: ID_EX_T <= #2 B;
            HLT: ID_EX_T <= #2 H;
            default: ID_EX_T <= #2 H;
        endcase
    end
end

always @(posedge clk1) begin
    if (HA == 0) begin
        EX_MEM_T <= #2 ID_EX_T;
        EX_MEM_IR <= #2 ID_EX_IR;
        TAKEN_B <= #2 0;
        case (ID_EX_T)
            RR: begin
                case (ID_EX_IR[31:26])
                    ADD: EX_MEM_ALUo <= #2 ID_EX_A + ID_EX_B;
                    SUB: EX_MEM_ALUo <= #2 ID_EX_A - ID_EX_B;
                    AND: EX_MEM_ALUo <= #2 ID_EX_A & ID_EX_B;
                    OR: EX_MEM_ALUo <= #2 ID_EX_A | ID_EX_B;
                    SLT: EX_MEM_ALUo <= #2 ID_EX_A < ID_EX_B;
                    MUL: EX_MEM_ALUo <= #2 ID_EX_A * ID_EX_B;
                    default: EX_MEM_ALUo <= #2 32'hxxxxxxxx;
                endcase
            end
            RM: begin
                case (ID_EX_IR[31:26])
                    ADDI: EX_MEM_ALUo <= #2 ID_EX_A + ID_EX_Imm;
                    SUBI: EX_MEM_ALUo <= #2 ID_EX_A - ID_EX_Imm;
                    SLTI: EX_MEM_ALUo <= #2 ID_EX_A < ID_EX_Imm;
                    default: EX_MEM_ALUo <= #2 32'hxxxxxxxx;
                endcase
            end
            LOAD, STORE: begin
                EX_MEM_ALUo <= #2 ID_EX_A + ID_EX_Imm;
                EX_MEM_B <= #2 ID_EX_B;
            end
            B: begin
                EX_MEM_ALUo <= #2 ID_EX_NPC + ID_EX_Imm;
                EX_MEM_cond <= #2 (ID_EX_A == 0);
            end
        endcase
    end
end

always @(posedge clk2) begin
    if (HA == 0) begin
        MEM_WB_T <= #2 EX_MEM_T;
        MEM_WB_IR <= #2 EX_MEM_IR;
        case (EX_MEM_T)
            RR, RM: MEM_WB_ALUo <= #2 EX_MEM_ALUo;
            LOAD: MEM_WB_LMD <= #2 MEM[EX_MEM_ALUo];
            STORE: if (TAKEN_B == 0) MEM[EX_MEM_ALUo] <= #2 EX_MEM_B;
        endcase
    end
end

always @(posedge clk1) begin
    if (TAKEN_B == 0) begin
        case (MEM_WB_T)
            RR: Reg[MEM_WB_IR[15:11]] <= #2 MEM_WB_ALUo;
            RM: Reg[MEM_WB_IR[20:16]] <= #2 MEM_WB_ALUo;
            LOAD: Reg[MEM_WB_IR[20:16]] <= #2 MEM_WB_LMD;
            H: HA <= #2 1'b1;
        endcase
    end
end

endmodule
