`timescale 1ns / 1ps

module SRT_tb();
    reg     [3:0] x0,x1,x2,x3;
    reg     clk,rst;
    wire    [3:0] s0,s1,s2,s3;
    wire    done;
    
    SRT DUT (
        .x0(x0),
        .x1(x1),
        .x2(x2),
        .x3(x3),
        .clk(clk),
        .rst(rst),
        .s0(s0),
        .s1(s1),
        .s2(s2),
        .s3(s3),
        .done(done)
        );
        
    integer k;
    
    initial
    begin
        x0 = 4'd4;
        x1 = 4'd3;
        x2 = 4'd2;
        x3 = 4'd1;
        clk = 0;
        k = 0;
        rst = 0;
        #20 rst = 1;
        #20 rst = 0;
        #100 clk = ~clk;
        while (k < 15)
        begin
            #50 clk = ~clk;
            k = k + 1;
        end
    end
        
endmodule
