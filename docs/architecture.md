# Architecture and Functional Specification

## 1. Scope
Milestone 1 is a single-lane signed mixed-precision MAC. This deliberately small DUT makes arithmetic semantics and verification infrastructure testable before expansion into a 2x2 systolic array.

## 2. Datapath
1. Precision selection chooses signed INT8 operands or signed INT4 values from the low nibbles.
2. The multiplier produces a signed product represented on a 16-bit signal.
3. Accumulator control handles reset, clear, and addition.
4. The result-valid pipeline registers in_valid into out_valid.

## 3. Numeric ranges

| Mode | Operand range | Product range |
|---|---:|---:|
| Signed INT4 | -8 to +7 | -56 to +64 |
| Signed INT8 | -128 to +127 | -16,256 to +16,384 |

The accumulator is signed 32-bit. Overflow wraps in two's-complement arithmetic. The reference model must implement wrapping explicitly.

## 4. Priority at each rising edge
1. If rst_n is low, accumulator becomes zero and out_valid becomes zero.
2. Otherwise, out_valid captures in_valid.
3. If clear is high, accumulator becomes the current product when in_valid is high, otherwise zero.
4. Else if in_valid is high, accumulator adds the signed product.
5. Else the accumulator holds its previous value.

Reset is synchronous active-low. Inputs are sampled at the rising edge.

## 5. Milestone-1 non-goals
No backpressure, saturation, scaling/zero points, systolic wavefront, or PPA claims. These may be added only after the base behavior is specified and verified.

## 6. Planned 2x2 systolic-array extension
Add four processing elements, row/column operand propagation, per-PE partial sums, and explicit tile start/done behavior. Update the spec and scoreboard before implementing the extension. Keep the single-MAC regression as a fast unit test.
