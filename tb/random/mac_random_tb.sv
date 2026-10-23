// SPDX-License-Identifier: MIT
// Randomized, self-checking reference-model regression for mac_unit.
module mac_random_tb;
    logic clk = 1'b0;
    logic rst_n = 1'b0;
    logic in_valid = 1'b0;
    logic clear = 1'b0;
    logic precision_int4 = 1'b0;
    logic signed [7:0] a = '0;
    logic signed [7:0] b = '0;
    logic signed [31:0] accumulator;
    logic out_valid;

    logic signed [31:0] expected_acc;
    logic expected_valid;
    integer signed model_a;
    integer signed model_b;
    integer signed model_product;
    integer i;
    integer seed;

    mac_unit dut (
        .clk(clk), .rst_n(rst_n), .in_valid(in_valid), .clear(clear),
        .precision_int4(precision_int4), .a(a), .b(b),
        .accumulator(accumulator), .out_valid(out_valid)
    );

    always #5 clk = ~clk;

    task automatic apply_and_check(
        input logic valid_i,
        input logic clear_i,
        input logic int4_i,
        input logic signed [7:0] a_i,
        input logic signed [7:0] b_i,
        input logic reset_i
    );
        begin
            @(negedge clk);
            in_valid = valid_i;
            clear = clear_i;
            precision_int4 = int4_i;
            a = a_i;
            b = b_i;
            rst_n = reset_i;

            // Independent software-style reference model.
            if (!reset_i) begin
                expected_acc = 32'sd0;
                expected_valid = 1'b0;
            end else begin
                expected_valid = valid_i;
                if (int4_i) begin
                    model_a = $signed(a_i[3:0]);
                    model_b = $signed(b_i[3:0]);
                end else begin
                    model_a = $signed(a_i);
                    model_b = $signed(b_i);
                end
                model_product = model_a * model_b;

                if (clear_i) begin
                    if (valid_i)
                        expected_acc = model_product;
                    else
                        expected_acc = 32'sd0;
                end else if (valid_i) begin
                    expected_acc = expected_acc + model_product;
                end
            end

            @(posedge clk);
            #1;
            if (accumulator !== expected_acc || out_valid !== expected_valid) begin
                $error("MISMATCH cycle=%0d reset_n=%0b valid=%0b clear=%0b int4=%0b a=%0d b=%0d expected_acc=%0d actual_acc=%0d expected_valid=%0b actual_valid=%0b",
                       i, reset_i, valid_i, clear_i, int4_i, a_i, b_i,
                       expected_acc, accumulator, expected_valid, out_valid);
                $fatal(1, "Reference-model regression failed");
            end
        end
    endtask

    initial begin
        expected_acc = 32'sd0;
        expected_valid = 1'b0;
        seed = 32'h51A7C0DE;
        i = 0;
        void'($urandom(seed));

        $display("Starting randomized MAC reference-model regression");
        apply_and_check(1'b0, 1'b0, 1'b0, 8'sd0, 8'sd0, 1'b0);
        apply_and_check(1'b0, 1'b0, 1'b0, 8'sd0, 8'sd0, 1'b1);

        for (i = 0; i < 1000; i = i + 1) begin
            apply_and_check(
                ($urandom_range(0, 99) < 75),
                ($urandom_range(0, 99) < 8),
                ($urandom_range(0, 1) == 1),
                $urandom,
                $urandom,
                ($urandom_range(0, 999) != 0)
            );
        end

        // Directed extrema supplement random chance for signed boundaries.
        i = 1000;
        apply_and_check(1'b1, 1'b1, 1'b1, 8'h08, 8'h08, 1'b1); // -8 * -8
        i = 1001;
        apply_and_check(1'b1, 1'b1, 1'b0, 8'h80, 8'h80, 1'b1); // -128 * -128
        i = 1002;
        apply_and_check(1'b1, 1'b0, 1'b0, 8'h80, 8'h7f, 1'b1); // accumulate -16256

        $display("ALL TESTS PASSED: 1003 randomized/directed cycles");
        $finish;
    end
endmodule
