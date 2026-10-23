// SPDX-License-Identifier: MIT
// Milestone-1 top level. This is a single MAC lane, not yet a systolic array.
module accelerator_top (
    input  logic              clk,
    input  logic              rst_n,
    input  logic              in_valid,
    input  logic              clear,
    input  logic              precision_int4,
    input  logic signed [7:0] a,
    input  logic signed [7:0] b,
    output logic signed [31:0] accumulator,
    output logic              out_valid
);
    mac_unit u_mac_unit (
        .clk            (clk),
        .rst_n          (rst_n),
        .in_valid       (in_valid),
        .clear          (clear),
        .precision_int4 (precision_int4),
        .a              (a),
        .b              (b),
        .accumulator    (accumulator),
        .out_valid      (out_valid)
    );
endmodule
