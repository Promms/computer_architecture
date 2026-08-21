`timescale 100ps / 100ps

module ALU(
    input [15:0] A,
    input [15:0] B,
    input Cin,
    input [3:0] OP,
    output reg Cout,
    output reg [15:0] C
    );
    
// FILLME
parameter   OP_ADD = 4'b0000,
            OP_SUB	= 4'b0001,
            OP_ID = 4'b0010,
            OP_NAND = 4'b0011,
            OP_NOR = 4'b0100,
            OP_XNOR = 4'b0101,
            OP_NOT = 4'b0110,
            OP_AND = 4'b0111,
            OP_OR = 4'b1000,
            OP_XOR = 4'b1001,
            OP_LRS = 4'b1010,
            OP_ARS = 4'b1011,
            OP_RR = 4'b1100,
            OP_LLS = 4'b1101,
            OP_ALS = 4'b1110,
            OP_RL = 4'b1111;

task R_Shifter;
    input [15:0] A;
    input Sin;
    output reg Cout;
    output reg [15:0] C;

    begin
        C = {Sin, A[15:1]};
        Cout = 0;
    end
endtask

task L_Shifter;
    input [15:0] A;
    input Sin;
    output reg Cout;
    output reg [15:0] C;

    begin
        C = {A[14:0], Sin};
        Cout = 0;
    end
endtask

always @(*) begin
    case(OP)
        // Arithmetic
        OP_ADD: {Cout, C} = A + B + Cin;
        OP_SUB: {Cout, C} = A - B - Cin;
        // Bitwise Boolean Operation
        OP_ID: begin C = A; Cout = 0; end
        OP_NAND: begin C = ~(A & B); Cout = 0; end
        OP_NOR: begin C = ~(A | B); Cout = 0; end
        OP_XNOR: begin C = ~(A ^ B); Cout = 0; end
        OP_NOT: begin C = ~A; Cout = 0; end
        OP_AND: begin C = (A & B); Cout = 0; end
        OP_OR: begin C = (A | B); Cout = 0; end
        OP_XOR: begin C = (A ^ B); Cout = 0; end
        // Shifting
        OP_LRS: R_Shifter(A,0,Cout,C);
        OP_ARS: R_Shifter(A,A[15],Cout,C);
        OP_RR: R_Shifter(A,A[0],Cout,C);
        OP_LLS: L_Shifter(A,0,Cout,C);
        OP_ALS: L_Shifter(A,0,Cout,C);
        OP_RL: L_Shifter(A,A[15],Cout,C);
        default: begin C = 16'b0; Cout = 0; end 
    endcase
end

endmodule