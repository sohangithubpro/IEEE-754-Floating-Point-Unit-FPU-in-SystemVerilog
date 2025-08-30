// Code your testbench here
// or browse Examples


module tb;
  logic [31:0] a,b,out;
  logic [1:0] op;
  
  fpu dut(a,b,op,out);
  
  initial
    begin
      a=32'hADEC9810;
      b=32'hFBEC5183;
      op=2;
      #50;
      op=3;
    end
  
  
  initial
    begin
      $dumpfile("test.vcd");
      $dumpvars(0);
      #200;
      $finish;
    end
endmodule
