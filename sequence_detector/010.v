`timescale 100ps / 100ps

module detector_010 (clk, reset, in, out);
input clk, reset, in;
output reg out;

reg[1:0] S_curr, S_next;

parameter   Init = 2'b00,
            Got0 = 2'b01,
            Got01 = 2'b10,
            Got010 = 2'b11;

always @(S_curr, in) begin
    case(S_curr)
        Init: if(in == 0) S_next = Got0; else S_next = Init;
        Got0: if(in == 0) S_next = Got0; else S_next = Got01;
        Got01: if(in == 0) S_next = Got010; else S_next = Init;
        Got010: if(in == 0) S_next = Got0; else S_next = Got01;
        default: S_next = Init;
    endcase    
end

always @(S_curr) begin
    if(S_curr == Got010) out = 1; else out = 0;
end

always @(posedge clk) begin
    if(reset == 1) S_curr <= Init; else S_curr <= S_next;
end

endmodule
