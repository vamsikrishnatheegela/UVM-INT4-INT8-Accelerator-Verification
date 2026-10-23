# UVM environment: setup and run notes

## Implemented components

- accel_txn: sequence item carrying reset, valid, clear, precision, and operand fields.
- accel_random_sequence: drives one reset transaction followed by 1,000 randomized operations.
- accel_driver: drives the virtual interface on the falling edge.
- accel_monitor: samples DUT inputs and outputs and publishes observed transactions.
- accel_scoreboard: maintains an independent accumulator model and checks accumulator/out_valid every sampled cycle.
- accel_agent and accel_env: connect sequencer, driver, monitor, and scoreboard.
- accel_test: starts the sequence and manages the UVM objection.
- Monitor covergroup: precision, valid, clear, signed operand bits, and precision/valid plus clear/valid crosses.

## Important simulator note

The UVM environment is source code and has not yet been compiled or simulated. The existing local regression uses Verilator and remains the verified open-source path. Full UVM execution requires a simulator with a compatible UVM library, such as Xcelium, Questa, or VCS, plus the appropriate simulator-specific command line.

## Generic compile-order guidance

The simulator command must compile the simulator's UVM library and define UVM_HOME appropriately. Use sim/uvm_filelist.f as a starting file list, but adjust library flags and UVM library paths for the installed simulator. Do not assume this file list runs unchanged on every simulator.

## Review before claiming coverage closure

- Confirm the simulator supports the UVM version and covergroup syntax used.
- Check monitor sampling semantics against the simulator scheduling model.
- Review scoreboard mismatch count and UVM report summary.
- Inspect functional coverage report and add missing bins/crosses.
- Add a CI job on a UVM-capable licensed runner if available.
