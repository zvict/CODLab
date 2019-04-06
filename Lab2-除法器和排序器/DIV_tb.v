`timescale 1ns / 1ps

module DIV_tb();
    
    reg     [3:0] x,y;
    reg     clk,rst;
    wire    [3:0] q,r;
    wire    error,done;
    wire    [4:0] xt,yt;
    wire    [2:0] state;
    wire    [4:0] xout,yout;
    wire    flag;
    
    DIV DUT (
        .x(x),
        .y(y),
        .clk(clk),
        .rst(rst),
        .q(q),
        .r(r),
        .error(error),
        .done(done)
//        .xt(xt),
//        .yt(yt),
//        .state(state),
//        .flag(flag),
//        .xout(xout),
//        .yout(yout)
        );
        
    integer k;
    
    initial
    begin
        x = 4'b1111;
        y = 4'b0010;
        rst = 0;
        clk = 0;
        k = 0;
        #20 rst = 1;
        #20 rst = 0;
        #100 clk = 1;
        while (k < 130)
        begin
            #50 clk = ~clk;
            k = k + 1;
        end
//        y = 4'b0000;
//        #20 rst = 1;
//        #20 rst = 0;
//        #100 clk = ~clk;
//        while (k < 18)
//        begin
//            #50 clk = ~clk;
//            k = k + 1;
//        end
    end
    
endmodule
