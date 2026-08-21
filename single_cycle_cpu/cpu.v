///////////////////////////////////////////////////////////////////////////
// MODULE: CPU for TSC microcomputer: cpu.v
// Author: 
// Description: 

// DEFINITIONS
`define WORD_SIZE 16    // data and address word size

`define OP_RTYPE 4'b1111
`define OP_LHI 4'b0110
`define OP_ADI 4'b0100
`define OP_JMP 4'b1001

`define OP_ADD 6'b000000
`define OP_WWD 6'b011100

// MODULE DECLARATION
module cpu (
    output readM,                       // read from memory
    output [`WORD_SIZE-1:0] address,    // current address for data
    inout [`WORD_SIZE-1:0] data,        // data being input or output
    input inputReady,                   // indicates that data is ready from the input port
    input reset_n,                      // active-low RESET signal
    input clk,                          // clock signal
  
    // for debuging/testing purpose
    output [`WORD_SIZE-1:0] num_inst,   // number of instruction during execution
    output [`WORD_SIZE-1:0] output_port // this will be used for a "WWD" instruction
);

    reg [`WORD_SIZE-1:0] instruction;           // data에서 가져온 instruction을 저장할 공간
    reg [`WORD_SIZE-1:0] Current_PC;            // 현재 PC를 clk에 동기화하기 위해 선언
    wire [`WORD_SIZE-1:0] Next_PC;              // 다음 PC는 Combination Logic에서 계산하기 위해 wire로 선언

    reg [`WORD_SIZE-1:0] Current_output_port;   // 그냥 wire로만 하고 돌렸을 때 한 칸씩 앞 당겨져 출력되는 오류가 있어 PC처럼 수정해봄
    wire [`WORD_SIZE-1:0] Next_output_port;

    // sequential logic에서 사용하기 위해 선언
    reg [`WORD_SIZE-1:0] num_inst;              
    reg readM;

    // Control Unit -> Data Path Signal
    wire isR;
    wire isWrite;
    wire isADI;
    wire isJMP;
    wire isWWD;
    wire isLHI;
    wire [5:0] ALU_Function;    // ADI나 LHI 같은 명령어에서는 function code를 ADD로 바꿔주어야 하는데 이를 CU가 수행

    Control_Unit CU(instruction[15:12], instruction[5:0], isR, isWrite, isADI, isJMP, isWWD, isLHI, ALU_Function);
    Datapath DP(clk, reset_n, Current_PC, instruction, isR, isWrite, isADI, isJMP, isWWD, isLHI, ALU_Function, Next_PC, Next_output_port);

    // output을 내부 변수와 연결
    assign address = Current_PC;
    assign output_port = Current_output_port;
    
    initial begin 
        num_inst = 0; 
        Current_PC = 0;
    end
    
    always @(reset_n == 0) begin
        num_inst = 0;
        Current_PC = 0;
    end
    
    // inputReady가 1일 때만 data를 instruction으로 읽어옴
    always @(inputReady) begin
        if(inputReady == 1) begin 
            instruction = data;
            readM = 0;
        end
    end

    // 한 개 사이클이 지날 때 마다 num_inst를 올려주고 readM을 활성화
    always @(posedge clk) begin
        num_inst <= num_inst + 1;
        readM <= 1;
    end

    // 걸리는점 => 교수님이 같은 변수를 여러 개의 always 블록에서 사용하지 말라고 했는데 readM을 2곳에서 사용..

    // PC를 update
    always @(posedge clk) begin
        Current_PC <= Next_PC;
        Current_output_port <= Next_output_port;
    end
    
endmodule


module Control_Unit (
    input [3:0] opcode,
    input [5:0] function_code,
    output isR,
    output isWrite,
    output isADI,
    output isJMP,
    output isWWD,
    output isLHI,
    output [5:0] ALU_Function
);

    assign isR = (opcode == `OP_RTYPE);
    assign isADI = (opcode == `OP_ADI);
    assign isLHI = (opcode == `OP_LHI);
    assign isJMP = (opcode == `OP_JMP);
    assign isWWD = (opcode == `OP_RTYPE) && (function_code == `OP_WWD); // 우연히 하위 6비트가 WWD일 수도 있음

    assign isWrite = (isR && (function_code == `OP_ADD)) || isADI || isLHI;
    assign ALU_Function = isR ? function_code : `OP_ADD;
endmodule


module Datapath (
    input clk,
    input reset_n,

    input [`WORD_SIZE-1:0] PC,
    input [`WORD_SIZE-1:0] instruction,
    input isR,
    input isWrite,
    input isADI,
    input isJMP,
    input isWWD,
    input isLHI,
    input [5:0] ALU_Function,

    output [`WORD_SIZE-1:0] Next_PC,
    output [`WORD_SIZE-1:0] Next_output_port
);

    // Instruction Decode
    wire [1:0] rs = instruction[11:10];
    wire [1:0] rt = instruction[9:8];
    wire [1:0] rd = instruction[7:6];
    wire [7:0] immediate = {instruction[7:0]};
    wire [11:0] target_address = instruction[11:0];

    wire [15:0] sign_extented_imm = {{8{instruction[7]}}, instruction[7:0]};
    wire [15:0] LHI_imm = {immediate[7:0], 8'b00000000};

    // RF
    wire [1:0] SA = rs;
    wire [1:0] SB = rt;
    wire [1:0] DR = isR ? rd : rt; // I type 연산은 rt가 destination register일 수 있음

    wire [`WORD_SIZE-1:0] data_A;
    wire [`WORD_SIZE-1:0] data_B;

    // ALU
    wire [`WORD_SIZE-1:0] ALU_SrcA = isLHI ? 16'b0 : data_A; // LHI 연산을 0 + LHI_imm으로 해서 ALU를 그냥 통과하도록 함
    wire [`WORD_SIZE-1:0] ALU_SrcB = isADI ? sign_extented_imm : (isLHI ? LHI_imm : data_B); // ADI일 때는 imm이, LHI일 때는 LHI_imm이, 그 외에는 data_B가 들어감
    wire [`WORD_SIZE-1:0] ALU_Result;
    
    wire [`WORD_SIZE-1:0] D_in = ALU_Result; // ALU의 결과를 write하기 위해

    Register_File RF(clk, reset_n, SA, SB, DR, D_in, isWrite, data_A, data_B);
    Arithmetic_Logic_Unit ALU(ALU_SrcA, ALU_SrcB, ALU_Function, ALU_Result);

    // WWD 연산이라면 ALU_Result를 output port로 (ALU에서 WWD 연산은 그냥 Src_A를 반환하기 때문)
    assign Next_output_port = isWWD ? ALU_Result : 0;
    // JMP 연산자면 target address로 아니면 PC+1로 이동
    assign Next_PC = isJMP ? {PC[15:12], target_address} : (PC + 1);
endmodule

module Register_File (
    input clk,
    input reset_n,

    input [1:0] SA,
    input [1:0] SB,
    input [1:0] DR,
    input [`WORD_SIZE-1:0] D_in,
    input isWrite,

    output reg [`WORD_SIZE-1:0] data_A,
    output reg [`WORD_SIZE-1:0] data_B
);

    reg [`WORD_SIZE-1:0] registers[3:0];

    always @(*) begin
        data_A = registers[SA];
        data_B = registers[SB];
    end

    always @(posedge clk) begin
        if(reset_n == 0) begin
            registers[0] <= 16'b00;
            registers[1] <= 16'b00;
            registers[2] <= 16'b00;
            registers[3] <= 16'b00;
        end
        else if(isWrite == 1) begin
            registers[DR] <= D_in;
        end
    end
endmodule

module Arithmetic_Logic_Unit(
    input [`WORD_SIZE-1:0] ALU_SrcA,
    input [`WORD_SIZE-1:0] ALU_SrcB,
    input [5:0] ALU_Function,

    output reg [`WORD_SIZE-1:0] ALU_Result
);
    // 과제에서 요구한 ADD랑 WWD만 구현함
    always @(*) begin
        case(ALU_Function)
            `OP_ADD: ALU_Result = ALU_SrcA + ALU_SrcB;
            `OP_WWD: ALU_Result = ALU_SrcA;
            default: ALU_Result = 16'b0;
        endcase
    end

endmodule
