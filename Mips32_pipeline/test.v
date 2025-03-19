`timescale 1ns / 1ps


module test_mips32;
reg clk1,clk2;
  integer k;
   mips32 mips(clk1, clk2);
  initial
  begin
    clk1 = 0;
    clk2 = 0;
    repeat (20) 
    begin
      #5 clk1 = 1;
      #5 clk1 = 0;
      #5 clk2 = 1;
      #5 clk2 = 0;
    end
  end
   initial
  begin
    for (k=0; k<31; k=k+1)
      mips.Reg[k] = k;
    mips.MEM[0] = 32'h2801000a; // ADDI R1,R0,10
    mips.MEM[1] = 32'h28020014; // ADDI R2,R0,20
    mips.MEM[2] = 32'h28030019; // ADDI R3,R0,25
    mips.MEM[3] = 32'h0ce77800; // OR R7,R7,R7 -- dummy instr.
    mips.MEM[4] = 32'h0ce77800; // OR R7,R7,R7 -- dummy instr.
    mips.MEM[5] = 32'h00222000; // ADD R4,R1,R2
    mips.MEM[6] = 32'h0ce77800; // OR R7,R7,R7 -- dummy instr.
    mips.MEM[7] = 32'h00832800; // ADD R5,R4,R3
    mips.MEM[8] = 32'hfc000000; // HLT
    mips.HA = 0;
    mips.PC = 0;
    mips.TAKEN_B = 0;
    #280
     for (k=0; k<6; k=k+1)
       $display ("R%1d - %2d", k, mips.Reg[k]);
  end
  initial
  begin
    $dumpfile ("mips.vcd");
    $dumpvars (0, test_mips32);
    #300 $finish;
  end
endmodule
