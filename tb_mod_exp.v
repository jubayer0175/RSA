`timescale 1ns / 1ps
`include "defines.vh"


module tb_mod_exp;

    reg clk, rst, in_valid;
    reg [`BITS-1:0] m, e, n, r2;
    wire [`BITS-1:0] out;
    wire out_valid;
    
    mod_exp dut(.clk(clk),
                .rst(rst),
                .m(m),
                .e(e),
                .n(n),
                .r2(r2),
                .out(out),
                .in_valid(in_valid),
                .out_valid(out_valid));
    
    initial begin 
          #0 clk <= 0;
          #0 rst <= 1;
         // #0 m <= `BITS'd305419896;
          //#0 e <= `BITS'd2271560481;
           #0 m <= `BITS'he6b3abf5;
           #0 e <= `BITS'h11;
           #0 n <= `BITS'd44292017463532640823;
          #0 r2 <= `BITS'd118772121022040735; // for 64 bit 
          #0 in_valid <= 1;
          #20 rst <= 0;
          #50 in_valid <= 0;
    end
    
    always #10 clk=~clk;
    
endmodule
