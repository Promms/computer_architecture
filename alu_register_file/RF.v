`timescale 100ps / 100ps

module RF(
    input [1:0] addr1,
    input [1:0] addr2,
    input [1:0] addr3,
    input [15:0] data3,
    input write,
    input clk,
    input reset,
    output reg [15:0] data1,
    output reg [15:0] data2
    );
    
    // FILLME
    reg [15:0] register1 = 16'b00;
    reg [15:0] register2 = 16'b00;
    reg [15:0] register3 = 16'b00;
    reg [15:0] register4 = 16'b00;

    parameter   add_reg1 = 2'b00,
                add_reg2 = 2'b01,
                add_reg3 = 2'b10,
                add_reg4 = 2'b11;

    always @(*) begin
        case (addr1)
            add_reg1: data1 = register1;
            add_reg2: data1 = register2;
            add_reg3: data1 = register3;
            add_reg4: data1 = register4;
            default:;
        endcase

        case (addr2)
            add_reg1: data2 = register1;
            add_reg2: data2 = register2;
            add_reg3: data2 = register3;
            add_reg4: data2 = register4;
            default:;
        endcase
    end


    always @(posedge clk) begin
        if(reset == 1) begin
            register1 <= 16'b00;
            register2 <= 16'b00;
            register3 <= 16'b00;
            register4 <= 16'b00;
        end
        else if(write == 1) begin
            case(addr3)
                add_reg1: register1 <= data3;
                add_reg2: register2 <= data3;
                add_reg3: register3 <= data3;
                add_reg4: register4 <= data3;
                default: ;
            endcase
        end
    end
    
endmodule