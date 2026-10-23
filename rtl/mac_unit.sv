// SPDX-License-Identifier: MIT
// Single-lane signed INT4/INT8 multiply-accumulate unit.
module mac_unit (
    input  logic              clk,
    input  logic              rst_n,          // synchronous active-low reset
    input  logic              in_valid,
    input  logic              clear,
    input  logic              precision_int4, // 1: signed INT4, 0: signed INT8
    input  logic signed [7:0] a,
    input  logic signed [7:0] b,
    output logic signed [31:0] accumulator,
    output logic              out_valid
);

    logic signed [3:0]  a_int4, b_int4;
    logic signed [7:0]  a_int8, b_int8;
    logic signed [15:0] product;
    logic signed [31:0] product_ext;

    always_comb begin
        a_int4 = a[3:0];
        b_int4 = b[3:0];
        a_int8 = a;
        b_int8 = b;

        if (precision_int4)
            product = $signed(a_int4) * $signed(b_int4);
        else
            product = $signed(a_int8) * $signed(b_int8);

        product_ext = {{16{product[15]}}, product};
    end

    always_ff @(posedge clk) begin
        if (!rst_n) begin
            accumulator <= 32'sd0;
            out_valid   <= 1'b0;
        end else begin
            out_valid <= in_valid;
            if (clear) begin
                if (in_valid)
                    accumulator <= product_ext;
                else
                    accumulator <= 32'sd0;
            end else if (in_valid) begin
                // 32-bit two's-complement wraparound is intentional.
                accumulator <= accumulator + product_ext;
            end
        end
    end
endmodule
