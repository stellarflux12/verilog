// Code your design here
// Code your design here
module full_adder(output logic sum,cout,input logic a,b,cin);
  logic x1,a1,a2;
  xor(x1,a,b);
  xor(sum,x1,cin);
  
  and(a1,x1,cin);
  and(a2,a,b);
  or(cout,a1,a2);
endmodule

module ripple_adder #(parameter m = 4) (
    output logic [m-1:0] sum,
    output logic cout,
    input logic [m-1:0] a, b,
    input logic cin
);

  logic [m:0]c;
   assign c[0] = cin; 
   genvar i;
    generate
        for (i = 0; i < m; i = i + 1) begin : adder_chain  
            full_adder FA ( 
                .sum(sum[i]), 
                .cout(c[i + 1]), 
                .a(a[i]), 
                .b(b[i]), 
                .cin(c[i]) 
            );
        end
    endgenerate
  assign cout=c[m];
endmodule
