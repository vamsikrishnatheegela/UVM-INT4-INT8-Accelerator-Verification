# Verification Plan

## Objectives
Demonstrate that the MAC implements the arithmetic contract for both precision modes, control combinations, and legal sequences. Detect signedness errors, incorrect nibble selection, valid-timing errors, clear-priority bugs, and accumulator update errors.

## Verification layers
1. RTL lint and elaboration.
2. Directed tests for reset, one operation, clear, clear+valid, idle hold, negative operands, extremes, and back-to-back requests.
3. Independent reference model with explicit 32-bit wraparound.
4. Scoreboard comparing expected and observed state each cycle.
5. Assertions for reset, valid pipeline, idle hold, and clear behavior.
6. Constrained-random tests with reproducible seeds.
7. Functional coverage for precision, signs, boundaries, controls, and mode transitions.
8. Regression script and concise pass/fail report.

## Initial test list
- Reset across multiple rising edges.
- INT4: 0x0, -8x-8, -8x7, 7x7.
- INT8: 0x0, -128x-128, -128x127, 127x127.
- Positive/negative operand combinations in both modes.
- Change upper nibbles while keeping INT4 low nibbles fixed.
- Accumulate several products without clear.
- Clear while idle.
- Clear and valid asserted together.
- Idle cycles after an operation.
- Alternate INT4 and INT8 on consecutive accepted operations.
- Randomized sequences with reproducible seeds.
- Reset during activity.

## Initial coverage targets
- Both precision modes.
- All four operand-sign combinations in each mode, with zero covered separately.
- Clear/valid cross: 00, 01, 10, 11.
- Boundary operands in each mode.
- INT4-to-INT8 and INT8-to-INT4 transitions.
- Multi-operation accumulation and clear+valid restart in both modes.

These are target goals, not measured coverage. Record actual results only after running a simulator.
