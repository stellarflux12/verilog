
module full_adder(output sum,cout,input a,b,cin);
  wire x1,a1,a2;
  xor(x1,a,b);
  xor(sum,x1,cin);
  
  and(a1,x1,cin);
  and(a2,a,b);
  or(cout,a1,a2);
endmodule

module ripple_adder #(parameter m = 4) (
    output  [m-1:0] sum,
    output  cout,
    input  [m-1:0] a, b,
    input  cin
);

  wire [m:0]c;
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

module carry_skip_adder#(parameter m = 4) (
    output  [m-1:0] sum,
    output  cout,
    input  [m-1:0] a, b,
    input  cin
);
  wire rcout;
  integer i;
  wire p;
  assign p = &({a ^ b});
 
  
  ripple_adder ra(.sum(sum),.cout(rcout),.a(a),.b(b),.cin(cin));
 
  assign cout=p?cin:rcout;
endmodule
