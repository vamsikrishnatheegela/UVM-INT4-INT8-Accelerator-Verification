// SPDX-License-Identifier: MIT
// UVM environment for the single-lane INT4/INT8 MAC milestone.
package accel_uvm_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    class accel_txn extends uvm_sequence_item;
        rand bit rst_n;
        rand bit in_valid;
        rand bit clear;
        rand bit precision_int4;
        rand bit [7:0] a;
        rand bit [7:0] b;
        bit signed [31:0] accumulator;
        bit out_valid;

        `uvm_object_utils_begin(accel_txn)
            `uvm_field_int(rst_n, UVM_ALL_ON)
            `uvm_field_int(in_valid, UVM_ALL_ON)
            `uvm_field_int(clear, UVM_ALL_ON)
            `uvm_field_int(precision_int4, UVM_ALL_ON)
            `uvm_field_int(a, UVM_ALL_ON)
            `uvm_field_int(b, UVM_ALL_ON)
            `uvm_field_int(accumulator, UVM_ALL_ON)
            `uvm_field_int(out_valid, UVM_ALL_ON)
        `uvm_object_utils_end

        constraint c_reset_rare { rst_n dist {1 := 99, 0 := 1}; }
        constraint c_valid_bias { in_valid dist {1 := 75, 0 := 25}; }
        constraint c_clear_bias { clear dist {1 := 8, 0 := 92}; }

        function new(string name = "accel_txn");
            super.new(name);
        endfunction
    endclass

    class accel_random_sequence extends uvm_sequence #(accel_txn);
        `uvm_object_utils(accel_random_sequence)
        function new(string name = "accel_random_sequence");
            super.new(name);
        endfunction

        task body();
            accel_txn tr;
            tr = accel_txn::type_id::create("reset_txn");
            start_item(tr);
            if (!tr.randomize() with {
                rst_n == 0; in_valid == 0; clear == 0; a == 0; b == 0;
            }) `uvm_fatal("RANDFAIL", "Could not randomize reset transaction")
            finish_item(tr);

            repeat (1000) begin
                tr = accel_txn::type_id::create("random_txn");
                start_item(tr);
                if (!tr.randomize() with { rst_n == 1; })
                    `uvm_fatal("RANDFAIL", "Could not randomize transaction")
                finish_item(tr);
            end
        endtask
    endclass

    class accel_driver extends uvm_driver #(accel_txn);
        `uvm_component_utils(accel_driver)
        virtual accel_if vif;

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            if (!uvm_config_db#(virtual accel_if)::get(this, "", "vif", vif))
                `uvm_fatal("NOVIF", "Driver could not get virtual interface")
        endfunction

        task run_phase(uvm_phase phase);
            accel_txn req;
            forever begin
                seq_item_port.get_next_item(req);
                @(negedge vif.clk);
                vif.rst_n          <= req.rst_n;
                vif.in_valid       <= req.in_valid;
                vif.clear          <= req.clear;
                vif.precision_int4 <= req.precision_int4;
                vif.a              <= req.a;
                vif.b              <= req.b;
                seq_item_port.item_done();
            end
        endtask
    endclass

    class accel_monitor extends uvm_component;
        `uvm_component_utils(accel_monitor)
        virtual accel_if vif;
        uvm_analysis_port #(accel_txn) ap;
        int unsigned samples;

        covergroup accel_cg with function sample(accel_txn t);
            cp_precision: coverpoint t.precision_int4 {
                bins int8 = {0}; bins int4 = {1};
            }
            cp_valid: coverpoint t.in_valid {
                bins idle = {0}; bins valid = {1};
            }
            cp_clear: coverpoint t.clear {
                bins no_clear = {0}; bins clear = {1};
            }
            cp_sign_a: coverpoint (t.precision_int4 ? t.a[3] : t.a[7]);
            cp_sign_b: coverpoint (t.precision_int4 ? t.b[3] : t.b[7]);
            precision_valid_cross: cross cp_precision, cp_valid;
            clear_valid_cross: cross cp_clear, cp_valid;
        endgroup

        function new(string name, uvm_component parent);
            super.new(name, parent);
            ap = new("ap", this);
            accel_cg = new();
            samples = 0;
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            if (!uvm_config_db#(virtual accel_if)::get(this, "", "vif", vif))
                `uvm_fatal("NOVIF", "Monitor could not get virtual interface")
        endfunction

        task run_phase(uvm_phase phase);
            accel_txn tr;
            forever begin
                @(posedge vif.clk);
                #1step;
                tr = accel_txn::type_id::create("observed_txn", this);
                tr.rst_n = vif.rst_n;
                tr.in_valid = vif.in_valid;
                tr.clear = vif.clear;
                tr.precision_int4 = vif.precision_int4;
                tr.a = vif.a;
                tr.b = vif.b;
                tr.accumulator = vif.accumulator;
                tr.out_valid = vif.out_valid;
                samples++;
                accel_cg.sample(tr);
                ap.write(tr);
            end
        endtask

        function void report_phase(uvm_phase phase);
            super.report_phase(phase);
            `uvm_info("COVERAGE", $sformatf("Transactions sampled: %0d; functional coverage: %0.2f%%",
                     samples, accel_cg.get_coverage()), UVM_LOW)
        endfunction
    endclass

    class accel_agent extends uvm_agent;
        `uvm_component_utils(accel_agent)
        uvm_sequencer #(accel_txn) sequencer;
        accel_driver driver;
        accel_monitor monitor;

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            sequencer = uvm_sequencer#(accel_txn)::type_id::create("sequencer", this);
            driver = accel_driver::type_id::create("driver", this);
            monitor = accel_monitor::type_id::create("monitor", this);
        endfunction

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            driver.seq_item_port.connect(sequencer.seq_item_export);
        endfunction
    endclass

    class accel_scoreboard extends uvm_component;
        `uvm_component_utils(accel_scoreboard)
        uvm_analysis_imp #(accel_txn, accel_scoreboard) analysis_export;
        bit signed [31:0] expected_acc;
        bit expected_valid;
        int unsigned checked;

        function new(string name, uvm_component parent);
            super.new(name, parent);
            analysis_export = new("analysis_export", this);
            expected_acc = 0;
            expected_valid = 0;
            checked = 0;
        endfunction

        function void write(accel_txn tr);
            int signed model_a;
            int signed model_b;
            int signed model_product;

            if (!tr.rst_n) begin
                expected_acc = 32'sd0;
                expected_valid = 0;
            end else begin
                expected_valid = tr.in_valid;
                if (tr.precision_int4) begin
                    model_a = $signed(tr.a[3:0]);
                    model_b = $signed(tr.b[3:0]);
                end else begin
                    model_a = $signed(tr.a);
                    model_b = $signed(tr.b);
                end
                model_product = model_a * model_b;
                if (tr.clear) begin
                    if (tr.in_valid) expected_acc = model_product;
                    else expected_acc = 32'sd0;
                end else if (tr.in_valid) begin
                    expected_acc = expected_acc + model_product;
                end
            end

            checked++;
            if (tr.accumulator !== expected_acc || tr.out_valid !== expected_valid)
                `uvm_error("SCOREBOARD", $sformatf(
                    "Mismatch #%0d: rst_n=%0b valid=%0b clear=%0b int4=%0b a=0x%02h b=0x%02h expected_acc=%0d actual_acc=%0d expected_valid=%0b actual_valid=%0b",
                    checked, tr.rst_n, tr.in_valid, tr.clear, tr.precision_int4,
                    tr.a, tr.b, expected_acc, tr.accumulator, expected_valid, tr.out_valid))
        endfunction

        function void report_phase(uvm_phase phase);
            super.report_phase(phase);
            `uvm_info("SCOREBOARD", $sformatf("Transactions checked: %0d", checked), UVM_LOW)
        endfunction
    endclass

    class accel_env extends uvm_env;
        `uvm_component_utils(accel_env)
        accel_agent agent;
        accel_scoreboard scoreboard;

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            agent = accel_agent::type_id::create("agent", this);
            scoreboard = accel_scoreboard::type_id::create("scoreboard", this);
        endfunction

        function void connect_phase(uvm_phase phase);
            super.connect_phase(phase);
            agent.monitor.ap.connect(scoreboard.analysis_export);
        endfunction
    endclass

    class accel_test extends uvm_test;
        `uvm_component_utils(accel_test)
        accel_env env;

        function new(string name, uvm_component parent);
            super.new(name, parent);
        endfunction

        function void build_phase(uvm_phase phase);
            super.build_phase(phase);
            env = accel_env::type_id::create("env", this);
        endfunction

        task run_phase(uvm_phase phase);
            accel_random_sequence seq;
            phase.raise_objection(this);
            seq = accel_random_sequence::type_id::create("seq");
            seq.start(env.agent.sequencer);
            repeat (2) @(posedge env.agent.driver.vif.clk);
            phase.drop_objection(this);
        endtask
    endclass
endpackage
