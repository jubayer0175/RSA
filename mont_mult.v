`timescale 1ns / 1ps
`include "defines.vh"


// Computes z = x * y * R^(-1) mod m, where R = 2^NUM_BITS > m
module mont_mult (clk, rst, x, y, m, z);

	input clk, rst;
	input [`BITS-1:0] x, y, m;
	output [`BITS-1:0] z;
	
	reg [`LOG_BITS:0] count;
	reg [`BITS-1:0] xreg, yreg, mreg, out;
	reg [`BITS+1:0] sum; // Larger to ensure there is no overflow
	
	assign z = out;
	
	always @(posedge clk or posedge rst)
	begin
		if (rst) begin
			count <= 0;
			sum <= 0;
			xreg <= x;
			yreg <= y;
			mreg <= m;
		end
		else begin
			if(count < `BITS) begin
				if(xreg[count]==1'b1) begin
                    sum = sum + {2'b00,yreg};
				end
				if(sum[0]==1'b1) begin
                    sum = sum + {2'b00,mreg};
				end
				 //sum = {1'b0, sum[`BITS+1:1]};
				    sum = sum >> 1;
				count = count + 1;
			end
			else begin
				if(sum>={2'b00,mreg}) begin
					sum = sum - {2'b00,mreg};
				end
				out = sum[`BITS-1:0];
			end
		end
	end
	
endmodule
