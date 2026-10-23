# Self-checking MAC smoke test

Run from the repository root:

```bash
chmod +x scripts/run_smoke.sh
./scripts/run_smoke.sh
```

The testbench checks reset, signed INT4/INT8 boundary products, accumulation, clear while idle, clear+valid restart, idle hold, and ignored upper bits in INT4 mode. It uses Verilator's timed SystemVerilog testbench support and does not require UVM.

A successful run ends with `ALL TESTS PASSED`. This is a focused smoke test, not a substitute for the planned UVM regression or coverage closure.
