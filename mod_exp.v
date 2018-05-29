`timescale 1ns / 1ps
`include "defines.vh"


// Computes z = m^e mod n
// Input m, e, n, r2, where r2 = R^2 mod n, R = 2^NUM_BITS
module mod_exp(clk, rst, m, e, n, r2, out, in_valid, out_valid);

    input clk, rst;
    input [`BITS-1:0] m, e, n, r2;
    output [`BITS-1:0] out;
    input in_valid;
    output out_valid;
    
    // States
    localparam IDLE = 3'b000, INIT1 = 3'b001, INIT2 = 3'b010, SQUARE = 3'b011, MULTIPLY = 3'b100, FINAL = 3'b101;
    
    reg [`LOG_BITS:0] sam_count, mm_count; // Counter for square and mult and for mont mult
    reg [2:0] state, next_state;
    reg [`BITS-1:0] mreg, ereg, nreg, r2reg, xbar, mbar, result;
    reg [`BITS-1:0] mm_out_temp, mm_a_temp, mm_b_temp;
    reg [`BITS-1:0] x, y;    // Registers for interfacing with montgomery multiplier
    reg mm_rst, mm_done, exp_done;
    wire [`BITS-1:0] mm_out;
    
    mont_mult MM (.clk(clk),
                  .rst(mm_rst),
                  .x(x),
                  .y(y),
                  .m(nreg),
                  .z(mm_out));
    
    assign out = result;
    assign out_valid = exp_done;
    
    task MontMult;
//        input [`BITS-1:0] a, b;
//        output [`BITS-1:0] c;
//        output valid_out;
        begin
            if(mm_count==1'b0) begin
                x <= mm_a_temp;
                y <= mm_b_temp;
                mm_count <= mm_count + 1;
//                valid_out <= 1'b0;
                mm_done = 1'b0;
            end
            else if(mm_count==1'b1) begin
                mm_rst <= 1'b1;
                mm_count <= mm_count + 1;
            end
            else if(mm_count<`BITS+4) begin
                mm_rst <= 1'b0;
                mm_count = mm_count + 1;
//                valid_out <= 1'b0;
                mm_done = 1'b0;
            end
            else begin
                mm_out_temp <= mm_out;
                mm_count <= 0;
//                valid_out <= 1'b1;
                mm_done = 1'b1;
            end
        end
    endtask

    always @(posedge clk or posedge rst)
    begin
        if (rst) begin
            state <= IDLE;
            next_state <= IDLE;
            result <= 0;
            exp_done <= 1'b0;// stop transmissting
        end
        else begin
            state = next_state;
            case(state)
                IDLE: begin
                exp_done <= 1'b0;
                    if(in_valid==1'b1) begin
                        mreg <= m;
                        ereg <= e;
                        nreg <= n;
                        r2reg <= r2;
                        sam_count <= `BITS;
                        mm_count <= 0;
                        result <= 0;
                        next_state <= INIT1;
                      
                    end
                end
                INIT1: begin // Calculate xbar for the running sum
//                    MontMult(1,r2reg,xbar,mm_done);
//                    if(mm_done==1'b1) begin
//                        next_state <= INIT2;
//                    end
                    xbar <= `BITS'd1278674219578988324;// this is R mod n
                    next_state <= INIT2;
                end
                INIT2: begin // Calculate montgomery domain version of m
                    mm_a_temp = mreg;
                    mm_b_temp = r2reg;
                    MontMult;
                    if(mm_done==1'b1) begin
                        next_state <= SQUARE;
                        mbar <= mm_out;
                    end
                end
                SQUARE: begin
                    if(sam_count>0) begin
                        mm_a_temp = xbar;
                        mm_b_temp = xbar;
                        MontMult;
                        if(mm_done==1'b1) begin
                            xbar <= mm_out;
                            if(ereg[sam_count-1]==1'b1) begin
                                next_state = MULTIPLY;
                            end
                            else begin
                                sam_count = sam_count - 1;
                            end
                        end
                    end
                    else begin
                        next_state = FINAL;
                    end
                end
                MULTIPLY: begin
                    mm_a_temp = mbar;
                    mm_b_temp = xbar;
                    MontMult;
                    if(mm_done==1'b1) begin
                        xbar <= mm_out;
                        next_state <= SQUARE;
                        sam_count = sam_count - 1;
                    end
                end
                FINAL: begin // Undo montgomery transform
                    mm_a_temp = xbar;
                    mm_b_temp = 1;
                    MontMult;
                    if(mm_done==1'b1) begin
                        result <= mm_out;
                        next_state <= IDLE;
                        exp_done <= 1'b1;
                    end
                end
            endcase
        end
    end
    
endmodule
