`timescale 1ns / 1ps
// This module interface the RSA encruption engine with the UART
`include "defines.vh"
module RSA(
 input clk,
 input rst,
 input [`BITS*2-1:0]Din,
 input Din_valid,
 output [`BITS-1:0]Dout,
 output  Dout_valid
    );
    
 
    
    
    
    
    // call modlar stuff: 
    mod_exp RSA_0(clk, rst, m, e, n, r2, out, in_valid, out_valid)
    
    
    
    
    
    
    
    
    
endmodule
