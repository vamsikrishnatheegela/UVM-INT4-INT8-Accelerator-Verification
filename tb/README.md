# Testbench implementation checklist

The initial interface is committed in interfaces/accel_if.sv. The following components remain to be implemented:

- transactions/accel_transaction.sv: randomized mode, operands, valid, and clear.
- agents/accel_driver.sv: drive the interface through a clocking block.
- agents/accel_monitor.sv: publish sampled transactions and observed outputs.
- agents/accel_agent.sv: assemble sequencer, driver, and monitor.
- reference_model: calculate signed INT4/INT8 products and explicit 32-bit wraparound independently.
- scoreboard/accel_scoreboard.sv: compare model state and DUT output each cycle.
- coverage/accel_coverage.sv: cover precision, signs, boundaries, clear/valid cross, and mode transitions.
- assertions/accel_sva.sv: check reset, valid latency, idle hold, and clear behavior.
- env/accel_env.sv: connect agent, scoreboard, and coverage.
- sequences/ and tests/: directed and constrained-random scenarios.

Compile the eventual UVM environment against the UVM version supplied with the selected simulator. Keep RTL lint separate from the UVM regression target.
