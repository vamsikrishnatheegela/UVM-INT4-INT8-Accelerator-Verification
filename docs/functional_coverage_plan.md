# Functional coverage plan

The current Verilator-compatible regression uses explicit counters rather than covergroups so it can run with the available open-source simulator. The counters are transaction-intent coverage, not a replacement for simulator coverage databases or class-based UVM covergroups.

## Required bins

| Coverage bin | Meaning |
|---|---|
| Reset cycles | Synchronous active-low reset was exercised |
| Valid INT4 operations | At least one accepted INT4 operation |
| Valid INT8 operations | At least one accepted INT8 operation |
| Clear + valid | Clear restarts accumulation with the current product |
| Clear while idle | Clear resets the accumulator when no operation is valid |
| Idle hold | Accumulator is expected to hold when neither clear nor valid is asserted |
| INT4 negative operand | INT4 signed-negative operand behavior was exercised |
| INT8 negative operand | INT8 signed-negative operand behavior was exercised |

The testbench fails if any required bin remains at zero. The seeded random stream provides repeatability, while directed tests guarantee key signed extrema are included.

## Next coverage upgrade

When moving to a UVM-capable simulator, implement covergroups and crosses such as:
- precision × valid;
- precision × clear;
- precision × operand sign;
- clear × valid;
- reset × valid;
- boundary operand classes: minimum, -1, 0, maximum.

Coverage closure should be based on a documented plan and meaningful bins, not just a high aggregate percentage.
