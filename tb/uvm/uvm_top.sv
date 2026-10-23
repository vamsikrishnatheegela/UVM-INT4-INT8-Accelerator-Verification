// SPDX-License-Identifier: MIT
`timescale 1ns/1ps
module uvm_top;
    import uvm_pkg::*;
    import accel_uvm_pkg::*;

    bit clk = 0;
    always #5 clk = ~clk;
    accel_if vif(clk);

    accelerator_top dut (
        .clk(clk), .rst_n(vif.rst_n), .in_valid(vif.in_valid),
        .clear(vif.clear), .precision_int4(vif.precision_int4),
        .a(vif.a), .b(vif.b), .accumulator(vif.accumulator),
        .out_valid(vif.out_valid)
    );

    initial begin
        vif.rst_n = 0;
        vif.in_valid = 0;
        vif.clear = 0;
        vif.precision_int4 = 0;
        vif.a = 0;
        vif.b = 0;
        uvm_config_db#(virtual accel_if)::set(null, "*", "vif", vif);
        run_test("accel_test");
    end

    initial begin
        #20000;
        $fatal(1, "Watchdog timeout: UVM test did not finish");
    end
endmodule
