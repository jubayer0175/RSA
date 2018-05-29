`timescale 1ns / 1ps
`include "defines.vh"


module tb_mont_mult;

    reg clk, rst;
    reg [`BITS-1:0] x, y, m;
    wire [`BITS-1:0] z;
    
    mont_mult dut(.clk(clk),
                  .rst(rst),
                  .x(x),
                  .y(y),
                  .m(m),
                  .z(z));
    
    initial begin 
          #0 clk <= 0;
          #0 rst <= 1;
          #0 x <= `BITS'd2193187897;
//          #0 x <= `BITS'd305419896;
//          #0 y <= `BITS'd2271560481;
          #0 y <= `BITS'd2193187897;
          #0 m <= `BITS'd4292870399;
          #20 rst <= 0;
    end
    
    always #10 clk=~clk;
    
endmodule
