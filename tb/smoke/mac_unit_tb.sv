`timescale 1ns/1ps

module mac_unit_tb;
    logic clk = 1'b0;
    logic rst_n = 1'b0;
    logic in_valid = 1'b0;
    logic clear = 1'b0;
    logic precision_int4 = 1'b0;
    logic signed [7:0] a = '0;
    logic signed [7:0] b = '0;
    logic signed [31:0] accumulator;
    logic out_valid;

    int checks = 0;

    always #5 clk = ~clk;

    mac_unit dut (
        .clk(clk),
        .rst_n(rst_n),
        .in_valid(in_valid),
        .clear(clear),
        .precision_int4(precision_int4),
        .a(a),
        .b(b),
        .accumulator(accumulator),
        .out_valid(out_valid)
    );

    task automatic check_state(
        input string label,
        input logic signed [31:0] expected_acc,
        input logic expected_valid
    );
        begin
            if (accumulator !== expected_acc) begin
                $error("[%s] accumulator mismatch: expected %0d (0x%08h), got %0d (0x%08h)",
                       label, expected_acc, expected_acc, accumulator, accumulator);
                $fatal(1);
            end
            if (out_valid !== expected_valid) begin
                $error("[%s] out_valid mismatch: expected %0b, got %0b",
                       label, expected_valid, out_valid);
                $fatal(1);
            end
            checks++;
            $display("PASS: %s | accumulator=%0d out_valid=%0b",
                     label, accumulator, out_valid);
        end
    endtask

    task automatic apply_op(
        input string label,
        input logic valid_i,
        input logic clear_i,
        input logic int4_i,
        input integer a_i,
        input integer b_i,
        input logic signed [31:0] expected_acc,
        input logic expected_valid
    );
        begin
            @(negedge clk);
            in_valid = valid_i;
            clear = clear_i;
            precision_int4 = int4_i;
            a = a_i;
            b = b_i;
            @(posedge clk);
            #1;
            check_state(label, expected_acc, expected_valid);
        end
    endtask

    initial begin
        $display("Starting MAC self-checking smoke tests");

        // Synchronous active-low reset is sampled on rising edges.
        rst_n = 1'b0;
        repeat (2) @(posedge clk);
        #1;
        check_state("reset", 32'sd0, 1'b0);

        @(negedge clk);
        rst_n = 1'b1;

        apply_op("INT4 -8 * -8 with clear", 1, 1, 1, -8, -8, 32'sd64, 1);
        apply_op("INT4 accumulate -8 * 7", 1, 0, 1, -8, 7, 32'sd8, 1);

        apply_op("INT8 -128 * -128 with clear", 1, 1, 0, -128, -128, 32'sd16384, 1);
        apply_op("INT8 accumulate -128 * 127", 1, 0, 0, -128, 127, 32'sd128, 1);

        apply_op("clear while idle", 0, 1, 0, 3, 4, 32'sd0, 0);
        apply_op("first accumulation 3 * 4", 1, 0, 0, 3, 4, 32'sd12, 1);
        apply_op("second accumulation 2 * 5", 1, 0, 0, 2, 5, 32'sd22, 1);
        apply_op("clear plus valid restarts at -3 * 4", 1, 1, 0, -3, 4, -32'sd12, 1);
        apply_op("idle holds accumulator", 0, 0, 0, 99, 99, -32'sd12, 0);

        // Upper bits intentionally disagree with the signed INT4 interpretation.
        // 8'h08 has low nibble 1000b (-8 in INT4); 8'hF7 has low nibble 0111b (+7).
        apply_op("INT4 ignores upper operand bits", 1, 1, 1, 8'h08, 8'hF7, -32'sd56, 1);

        $display("ALL TESTS PASSED: %0d checks", checks);
        $finish;
    end
endmodule
