# Computer Architecture Coursework

Verilog로 디지털 논리의 기초부터 16-bit single-cycle CPU까지 단계적으로 구현한 컴퓨터구조 수업 프로젝트입니다. 각 폴더의 소스는 실제 제출 ZIP을 기준으로 정리했습니다.

## Project progression

| Project | Topic | Main concepts |
| --- | --- | --- |
| 01 | `010` sequence detector | Moore FSM, overlapping pattern detection, synchronous state update |
| 02 | ALU and register file | 16-bit arithmetic/logic/shift operations, dual-read register file |
| 03 | Single-cycle CPU | control unit, datapath, register file, ALU, instruction execution |

Project 03 implements the coursework subset of a 16-bit TSC architecture and supports `LHI`, `ADI`, `ADD`, `JMP`, and `WWD` instructions.

## Directory layout

```text
computer_architecture/
├─ sequence_detector/
├─ alu_register_file/
└─ single_cycle_cpu/
```

Each project contains the submitted design source and its supplied testbench. Assignment PDFs, Vivado project files, screenshots, and submission archives are intentionally excluded.

## Multicore computing

`single_cycle_cpu`를 바탕으로 멀티코어 컴퓨팅 수업의 후속 과제를 추가할 예정입니다.
