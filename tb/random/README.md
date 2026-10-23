# Randomized reference-model regression

This testbench drives 1,000 seeded randomized cycles plus reset and directed signed-boundary checks. It maintains a software-style reference model and compares the expected accumulator and valid output after each clock edge.

Run from the repository root:

```bash
chmod +x scripts/run_random.sh
./scripts/run_random.sh
```

This is a SystemVerilog self-checking regression that runs with Verilator; it is not itself a UVM test. The UVM class-based environment will be a separate layer for a simulator with UVM support.
