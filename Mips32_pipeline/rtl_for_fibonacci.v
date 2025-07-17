// Code your design here


`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    16:31:39 05/27/2025 
// Design Name: 
// Module Name:    mips_le 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module pipe_MIPS32 (
    input clk1, 
    input clk2,
    output reg [31:0] Reg1_out
   
   
);
// Internal Registers and Memory
reg [31:0] PC, IF_ID_IR, IF_ID_NPC;
reg [31:0] ID_EX_IR, ID_EX_NPC, ID_EX_A, ID_EX_B, ID_EX_Imm;
reg [2:0] ID_EX_type, EX_MEM_type, MEM_WB_type;
reg [31:0] EX_MEM_IR, EX_MEM_ALUOut, EX_MEM_B;
reg EX_MEM_cond;
reg [31:0] MEM_WB_IR, MEM_WB_ALUOut, MEM_WB_LMD;
reg [31:0] Reg [0:31];     // Register file
  reg [31:0] Mem [0:50];   // Memory
 integer i;
  reg [31:0] display_index=31;

// Opcodes
parameter ADD = 6'b000000, SUB = 6'b000001, AND = 6'b000010, OR = 6'b000011, 
          SLT = 6'b000100, MUL = 6'b000101, HLT = 6'b111111, LW = 6'b001000, 
          SW = 6'b001001, ADDI = 6'b001010, SUBI = 6'b001011, SLTI = 6'b001100, 
          BNEQZ = 6'b001101, BEQZ = 6'b001110, BEQ = 6'b001111;

// Instruction types
parameter RR_ALU = 3'b000, RM_ALU = 3'b001, LOAD = 3'b010, 
          STORE = 3'b011, BRANCH = 3'b100, HALT = 3'b101;

reg HALTED;
reg TAKEN_BRANCH;

// Initialize memory and registers
initial begin
    i=0;
    PC =0;  // Start execution at address 25 (100 in byte address)
    HALTED = 0;
    TAKEN_BRANCH = 0;
    
    // Initialize registers to 0
    for ( i = 0; i < 32; i = i + 1) begin
        Reg[i] = 32'd0;
    end
    
    // Initialize memory to 0
  for ( i = 0; i < 50 ; i = i + 1) begin
        Mem[i] = 32'd0;
    end
  Mem[30] = 10; // Find factorial of 10
  Mem[0]  = 32'h280A001E;  // ADDI R10, R0, 30
Mem[1]  = 32'h0CE77800;  // OR R7, R7, R7
Mem[2]  = 32'h28010000;  // ADDI R1, R0, 0
Mem[3]  = 32'h28020001;  // ADDI R2, R0, 1
  Mem[4]  = 32'h21450000;//LW R5 ,0(R10)
   Mem[5]  = 32'h280B0020;  // ADDI R11, R0, 32
Mem[6]  = 32'h25410001;  // SW R1, 1(R10)
Mem[7]  = 32'h25420002;  // SW R2, 2(R10)
Mem[8]  = 32'h00221800;  // ADD R3, R1, R2
  Mem[9]  = 32'h296B0001;  // ADDI R11, R11, 1
Mem[10] = 32'h0CE77800;  // OR R7, R7, R7
Mem[11] = 32'h25630000;  // SW R3, 0(R11)
Mem[12] = 32'h00400800;  // ADD R1, R2, R0
Mem[13] = 32'h00601000;  // ADD R2, R3, R0
Mem[14] = 32'h2CA50001;  // SUBI R5, R5, 1
Mem[15] = 32'h0CE77800;  // OR R7, R7, R7
Mem[16] = 32'h35A0FFF7;  // BNEQZ R5, loop (offset = -9)

  Mem[17] = 32'hfc000000; // HLT


end

// [Rest of the pipe_MIPS32 module implementation remains the same...]
// ==================== IF Stage ====================
always @(posedge clk1) begin
    if (!HALTED) begin
        if (((EX_MEM_IR[31:26] == BEQZ) && (EX_MEM_cond == 1'b1)) || 
            ((EX_MEM_IR[31:26] == BNEQZ) && (EX_MEM_cond == 1'b0)) ||
            ((EX_MEM_IR[31:26] == BEQ) && (EX_MEM_cond == 1'b1))) begin
            IF_ID_IR <= Mem[EX_MEM_ALUOut];
            TAKEN_BRANCH <= 1'b1;
            IF_ID_NPC <= EX_MEM_ALUOut + 1;
            PC <= EX_MEM_ALUOut + 1;
        end else begin
            IF_ID_IR <= Mem[PC];
            IF_ID_NPC <= PC + 1;
            PC <= PC + 1;
           TAKEN_BRANCH <= 1'b0;
        end
    end
end

// ==================== ID Stage ====================
always @(posedge clk2) begin
    if (!HALTED) begin
        ID_EX_A <= (IF_ID_IR[25:21] == 5'b00000) ? 32'b0 : Reg[IF_ID_IR[25:21]];
        ID_EX_B <= (IF_ID_IR[20:16] == 5'b00000) ? 32'b0 : Reg[IF_ID_IR[20:16]];
        ID_EX_NPC <= IF_ID_NPC;
        ID_EX_IR <= IF_ID_IR;
        ID_EX_Imm <= {{16{IF_ID_IR[15]}}, IF_ID_IR[15:0]};

        case (IF_ID_IR[31:26])
            ADD, SUB, AND, OR, SLT, MUL: ID_EX_type <= RR_ALU;
            ADDI, SUBI, SLTI: ID_EX_type <= RM_ALU;
            LW: ID_EX_type <= LOAD;
            SW: ID_EX_type <= STORE;
            BNEQZ, BEQZ, BEQ: ID_EX_type <= BRANCH;
            HLT: ID_EX_type <= HALT;
            default: ID_EX_type <= HALT;
        endcase
    end
end

// ==================== EX Stage ====================
always @(posedge clk1) begin
    if (!HALTED) begin
        EX_MEM_type <= ID_EX_type;
        EX_MEM_IR <= ID_EX_IR;
        //TAKEN_BRANCH <= 1'b0;

        case (ID_EX_type)
            RR_ALU: begin
                case (ID_EX_IR[31:26])
                    ADD: EX_MEM_ALUOut <= ID_EX_A + ID_EX_B;
                    SUB: EX_MEM_ALUOut <= ID_EX_A - ID_EX_B;
                    AND: EX_MEM_ALUOut <= ID_EX_A & ID_EX_B;
                    OR:  EX_MEM_ALUOut <= ID_EX_A | ID_EX_B;
                    SLT: EX_MEM_ALUOut <= (ID_EX_A < ID_EX_B) ? 32'd1 : 32'd0;
                    MUL: EX_MEM_ALUOut <= ID_EX_A * ID_EX_B;
                    default: EX_MEM_ALUOut <= 32'hxxxxxxxx;
                endcase
            end
            
            RM_ALU: begin
                case (ID_EX_IR[31:26])
                    ADDI: EX_MEM_ALUOut <= ID_EX_A + ID_EX_Imm;
                    SUBI: EX_MEM_ALUOut <= ID_EX_A - ID_EX_Imm;
                    SLTI: EX_MEM_ALUOut <= (ID_EX_A < ID_EX_Imm) ? 32'd1 : 32'd0;
                    default: EX_MEM_ALUOut <= 32'hxxxxxxxx;
                endcase
            end
            
            LOAD, STORE: begin
                EX_MEM_ALUOut <= ID_EX_A + ID_EX_Imm;
                EX_MEM_B <= ID_EX_B;
            end
            
            BRANCH: begin
                EX_MEM_ALUOut <= ID_EX_NPC + ID_EX_Imm;
                case (ID_EX_IR[31:26])
                    BEQZ: EX_MEM_cond <= (ID_EX_A == 32'b0);
                    BNEQZ: EX_MEM_cond <= (ID_EX_A != 32'b0);
                    BEQ: EX_MEM_cond <= (ID_EX_A == ID_EX_B);
                    default: EX_MEM_cond <= 1'b0;
                endcase
            end
        endcase
    end
end

// ==================== MEM Stage ====================
always @(posedge clk2) begin
    if (!HALTED) begin
        MEM_WB_type <= EX_MEM_type;
        MEM_WB_IR <= EX_MEM_IR;

        case (EX_MEM_type)
            RR_ALU, RM_ALU: MEM_WB_ALUOut <= EX_MEM_ALUOut;
            LOAD: MEM_WB_LMD <= Mem[EX_MEM_ALUOut];
            STORE: if (TAKEN_BRANCH == 1'b0) begin
                Mem[EX_MEM_ALUOut] <= EX_MEM_B;
            end
        endcase
    end
end

// ==================== WB Stage ====================
always @(posedge clk1) begin
    if (TAKEN_BRANCH == 1'b0) begin
        case (MEM_WB_type)
            RR_ALU: Reg[MEM_WB_IR[15:11]] <= MEM_WB_ALUOut;
            RM_ALU: Reg[MEM_WB_IR[20:16]] <= MEM_WB_ALUOut;
            LOAD: Reg[MEM_WB_IR[20:16]] <= MEM_WB_LMD;
            HALT: HALTED <= 1'b1;
        endcase
    end
        // Update output registers
      
  if (!HALTED && display_index <= 41&& TAKEN_BRANCH == 1'b1) begin
            Reg1_out <= Mem[display_index];
            display_index <= display_index + 1;
        end
        

end

endmodule



module top_mips_system (
    input clk,             // Main FPGA clock
    input reset,          // Active-high reset
    output [31:0] Reg1_out // Output from register 1
);

    // Internal wires
    wire slow_clk;
    wire clk1, clk2;

    // Instantiate clock divider to slow down main clock
    clock_divider #( // parameterized divider
      .DIVIDE_BY(500000) // adjust this based on your FPGA clock and desired slow frequency
    ) slow_clk_gen (
        .clk_in(clk),
        .reset(reset),
        .clk_out(slow_clk)
    );

    // Instantiate clock sequencer
    clk_sequencer clock_gen (
        .clk(slow_clk),
        .reset(reset),
        .clk1(clk1),
        .clk2(clk2)
    );

    // Instantiate MIPS processor
    pipe_MIPS32 mips_processor (
        .clk1(clk1),
        .clk2(clk2),
        .Reg1_out(Reg1_out)
    );

endmodule
module clock_divider #(
    parameter DIVIDE_BY = 100
)(
    input clk_in,
    input reset,
    output reg clk_out
);

    reg [$clog2(DIVIDE_BY)-1:0] counter;

    always @(posedge clk_in or posedge reset) begin
        if (reset) begin
            counter <= 0;
            clk_out <= 0;
        end else begin
            if (counter == (DIVIDE_BY/2 - 1)) begin
                clk_out <= ~clk_out;
                counter <= 0;
            end else begin
                counter <= counter + 1;
            end
        end
    end

endmodule

module clk_sequencer (
    input clk,       // Master FPGA clock
    input reset,
    output reg clk1,
    output reg clk2
);

reg [1:0] state;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        state <= 0;
        clk1 <= 0;
        clk2 <= 0;
    end else begin
        case (state)
            2'b00: begin
                clk1 <= 1;
                clk2 <= 0;
                state <= 2'b01;
            end
            2'b01: begin
                clk1 <= 0;
                clk2 <= 1;
                state <= 2'b10;
            end
            2'b10: begin
                clk1 <= 0;
                clk2 <= 0;
                state <= 2'b00;
            end
            default: begin
                state <= 2'b00;
            end
        endcase
    end
end

endmodule
