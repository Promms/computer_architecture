# 16-bit ALU and Register File

Two reusable datapath components implemented in Verilog: a 16-bit ALU and a four-entry register file.

## ALU

`ALU.v` supports 16 operations selected by a 4-bit opcode:

- Arithmetic: add and subtract with carry input
- Boolean: identity, NAND, NOR, XNOR, NOT, AND, OR, and XOR
- Shift/rotate: logical and arithmetic shifts, rotate right, and rotate left

`ALU_TB.v` supplies self-checking cases for every operation and reports passed and failed cases.

## Register file

`RF.v` implements four 16-bit registers with:

- two combinational read ports
- one synchronous write port
- synchronous reset

`RF_TB.v` checks reset, reads, writes, and timing-sensitive access patterns.

## Simulation

```bash
iverilog -g2012 -o alu_sim ALU.v ALU_TB.v
vvp alu_sim

iverilog -g2012 -o rf_sim RF.v RF_TB.v
vvp rf_sim
```
