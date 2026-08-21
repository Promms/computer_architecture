# `010` Sequence Detector

A Moore finite-state machine that detects the bit sequence `010`. The transition design supports overlapping occurrences; after detecting `010`, the trailing `0` is retained as the beginning of a possible next match.

## Files

- `010.v`: sequence-detector implementation
- `010_tb.v`: self-checking testbench with a 128-bit input pattern

## Design

The FSM uses four states:

- `Init`: no useful prefix has been observed
- `Got0`: the current suffix is `0`
- `Got01`: the current suffix is `01`
- `Got010`: the target sequence has been detected

State changes occur on the rising edge of `clk`, and the active-high `reset` returns the detector to `Init`.

## Simulation

With Icarus Verilog installed:

```bash
iverilog -g2012 -o detector_sim 010.v 010_tb.v
vvp detector_sim
```

The supplied testbench reports the number of passed and failed output comparisons.
