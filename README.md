# UVM Verification of an INT4/INT8 MAC Accelerator

A verification-focused RTL project for a small mixed-precision multiply-accumulate (MAC) accelerator. The first milestone is a single MAC lane; the next milestone will expand it into a 2x2 systolic array and a reusable SystemVerilog/UVM environment.

**Current status:** synthesizable MAC RTL, lint helper, directed smoke test, randomized reference-model regression, lightweight coverage counters, and an initial UVM source environment are committed. The Verilator smoke and randomized regressions have passed locally. The UVM classes have not yet been compiled or simulated on a UVM-capable simulator; the repository is not yet fully verified.

## Goals
- Verify signed INT8 and signed INT4 MAC behavior.
- Check accumulation, clear/restart, reset, and back-to-back operations.
- Build an independent reference model and scoreboard.
- Add assertions, functional coverage, constrained-random tests, and regression reporting.

## Interface contract

| Signal | Direction | Meaning |
|---|---|---|
| clk, rst_n | input | Rising-edge clock; active-low synchronous reset |
| in_valid | input | Accept an operation on this rising edge |
| clear | input | Clear running sum; with in_valid, restart using the current product |
| precision_int4 | input | 1 selects signed INT4 from bits [3:0]; 0 selects signed INT8 |
| a, b | input | Signed operands carried on 8-bit buses |
| accumulator | output | Signed 32-bit running sum |
| out_valid | output | Registered copy of in_valid |

There is no backpressure in this first version: one operation can be accepted per clock. The accumulator updates on the accepting edge. out_valid is registered and corresponds to the in_valid sampled at that edge.

## Arithmetic rules
- INT8: interpret a[7:0] and b[7:0] as signed two's-complement values.
- INT4: interpret a[3:0] and b[3:0] as signed two's-complement values; upper bits are ignored.
- Product is sign-extended and added to a signed 32-bit accumulator.
- clear=1 and in_valid=0 clears the accumulator to zero.
- clear=1 and in_valid=1 sets the accumulator to the current product.
- Reset is synchronous and active-low.
- Accumulator overflow wraps in 32-bit two's-complement arithmetic.

## Layout
- rtl/ — synthesizable RTL
- tb/interfaces/ — testbench interface
- tb/ — planned UVM components and implementation checklist
- docs/ — architecture, verification plan, test matrix
- sim/ — source file list
- scripts/ — lint and later regression helpers
- reports/ — later generated summaries

## Start here
1. Read docs/architecture.md.
2. Read docs/verification_plan.md and docs/testplan.csv.
3. Run scripts/run_lint.sh to lint the RTL if Verilator is installed.
4. Run scripts/run_smoke.sh for directed checks.
5. Run scripts/run_random.sh for randomized reference-model checks and required coverage counters.
6. Review docs/uvm_run.md before compiling the UVM environment on a UVM-capable simulator.

A complete UVM run requires a simulator with compatible UVM support, such as Cadence Xcelium, Siemens Questa, or Synopsys VCS. Verilator availability alone does not guarantee support for the full UVM class library.

## Definition of done
The project is complete only after a reference model and scoreboard pass directed and randomized tests, assertions are exercised, coverage targets are met or justified, and reproducible simulator logs are documented. Do not report tests as passing until they have actually been run.
