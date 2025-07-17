// Code your testbench here
// or browse Examples
`timescale 1ns/1ps

module tb_mips;

  reg clk = 0;
  reg reset = 1;
  wire [31:0] Reg1_out;

  // Instantiate the top module
  top_mips_system uut (
    .clk(clk),
    .reset(reset),
    .Reg1_out(Reg1_out)
  );

  // Generate clock
  always #5 clk = ~clk;  // 10ns clock period

  initial begin
    // Dump VCD file for waveform viewing
    $dumpfile("dump.vcd");
    $dumpvars(0, tb_mips);

    // Initial reset
    #20 reset = 0;

    // Run long enough to see output
    #400000 $finish;
  end

endmodule
