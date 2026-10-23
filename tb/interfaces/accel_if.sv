interface accel_if(input logic clk);
    logic rst_n;
    logic in_valid;
    logic clear;
    logic precision_int4;
    logic signed [7:0] a;
    logic signed [7:0] b;
    logic signed [31:0] accumulator;
    logic out_valid;

    // Driver drives away from the active rising-edge sampling point.
    clocking drv_cb @(negedge clk);
        output rst_n, in_valid, clear, precision_int4, a, b;
    endclocking

    // #1step samples before active-region DUT updates at this edge.
    clocking mon_cb @(posedge clk);
        default input #1step;
        input rst_n, in_valid, clear, precision_int4, a, b;
        input accumulator, out_valid;
    endclocking

    modport DUT (
        input clk, rst_n, in_valid, clear, precision_int4, a, b,
        output accumulator, out_valid
    );
endinterface
