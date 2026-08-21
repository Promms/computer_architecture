# 16-bit Single-Cycle CPU

A coursework implementation of a 16-bit TSC single-cycle CPU. The design integrates instruction decoding, control signals, a datapath, a register file, and an ALU in one Verilog source.

## Supported instructions

| Instruction | Purpose |
| --- | --- |
| `LHI` | Load an immediate value into the high byte |
| `ADI` | Add a sign-extended immediate |
| `ADD` | Add two register operands |
| `JMP` | Jump to a target address |
| `WWD` | Send a register value to the output port |

## Modules

- `cpu`: program counter, memory handshake, instruction count, and output-port state
- `Control_Unit`: instruction decoding and datapath control
- `Datapath`: operand selection, register-file access, ALU connection, and next-PC logic
- `Register_File`: four 16-bit registers with two read ports and one write port
- `Arithmetic_Logic_Unit`: operations required by the coursework instruction subset

## Files

- `cpu.v`: submitted CPU design
- `cpu_tb.v`: supplied memory model, test program, and output checks

## Simulation

```bash
iverilog -g2012 -o cpu_sim cpu.v cpu_tb.v
vvp cpu_sim
```

## Scope

This is a course-specific instruction subset rather than a general-purpose CPU implementation.
