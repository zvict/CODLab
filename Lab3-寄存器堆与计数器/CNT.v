`timescale 1ns / 1ps

module CNT(d,pe,ce,rst,clk,q);
    parameter SIZE = 4;
    parameter MAX = 9;
    
    input   [SIZE:1] d;
    input   pe;
    input   ce;
    input   rst;
    input   clk;
    output  reg [SIZE:1] q;
    
    always @(posedge clk or posedge rst)
    begin
        if(rst)
            q <= 0;
        else if(pe)
            q <= d;
        else if(ce)
        begin
            if(q == MAX)
                q <= 0;
            else
                q <= q + 1;
        end
    end
    
endmodule
