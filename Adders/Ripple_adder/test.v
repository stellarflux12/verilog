class random;
   parameter m = 4; 
  randc logic [m-1:0] a,b;
  randc logic cin;
  constraint inp{   a inside {[0 : (1 << m) - 1]}; 
                 b inside {[0 : (1 << m) - 1]};cin inside {0, 1}; };
endclass

module ra;
  parameter m=4;
  logic [m-1:0] sum;
  logic cout;
  logic [m-1:0] a,b;
  logic cin;
  ripple_adder uut(.sum(sum),.cout(cout),.a(a),.b(b),.cin(cin));
random r;
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(1);
    r=new();
    repeat(10)begin
     assert(r.randomize()) else $fatal("Randomization failed !!");
        a=r.a;
        b=r.b;
        cin=r.cin;
      
      $monitor($time,"a=%d,b=%d,cin=%d,sum=%d,cout=%d\n",a,b,cin,sum,cout);
      #5;
    end
    $finish;
  end
endmodule
