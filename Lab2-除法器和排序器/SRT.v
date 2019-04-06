`timescale 1ns / 1ps

module SRT(clk,rst,done,x0,x1,x2,x3,s0,s1,s2,s3);
    input   [3:0] x0,x1,x2,x3;
    input   clk,rst;
    output  reg [3:0] s0,s1,s2,s3;
    output  reg done;
    
    parameter   st0 = 3'b000,
                 st1 = 3'b001,
                 st2 = 3'b010,
                 st3 = 3'b011,
                 st4 = 3'b100,
                 st5 = 3'b101,
                 st6 = 3'b110;
                 
    reg     [3:0] t0,t1;
    wire    [3:0] o0,o1;
    reg     [3:0] state;
    wire    flag;
    
    CMP cmp (
        .x0(t0),
        .x1(t1),
        .out(flag)
        );
    /*
    module CMP(x0,x1,out);
    
    input   [3:0] x0,x1;
    output  reg out;
     
    always @ (x0 or x1)
    begin
        if(x0 > x1)
            out = 1;
        else
            out = 0;
    end
    
	endmodule
	*/
    
    EXG exg (
        .x0(t0),
        .x1(t1),
        .out0(o0),
        .out1(o1)
        );
    /*
    module EXG(x0,x1,out0,out1);
    
    input   [3:0] x0,x1;
    output  [3:0] out0,out1;
    
    assign out0 = x1;
    assign out1 = x0;  
    
	endmodule
	*/
    
    always @ (posedge clk or posedge rst)
    begin
        if(rst)
        begin
            s0 <= x0;
            s1 <= x1;
            s2 <= x2;
            s3 <= x3;
            done <= 0;
            t0 <= x0;
            t1 <= x1;
            state <= st0;
        end
        else
            case(state)
                st0:begin
                        if(flag)
                        begin
                            s0 = o0;
                            s1 = o1;
                        end
                        t0 = s1;
                        t1 = s2;
                        state = st1;
                    end
                st1:begin
                        if(flag)
                        begin
                            s1 = o0;
                            s2 = o1;
                        end
                        t0 = s2;
                        t1 = s3;
                        state = st2;
                    end
                st2:begin
                        if(flag)
                        begin
                            s2 = o0;
                            s3 = o1;
                        end
                        t0 = s0;
                        t1 = s1;
                        state = st3;
                    end
                st3:begin
                        if(flag)
                        begin
                            s0 = o0;
                            s1 = o1;
                        end
                        t0 = s1;
                        t1 = s2;
                        state = st4;
                    end
                st4:begin
                        if(flag)
                        begin
                            s1 = o0;
                            s2 = o1;
                        end
                        t0 = s0;
                        t1 = s1;
                        state = st5;
                    end
                st5:begin
                        if(flag)
                        begin
                            s0 = o0;
                            s1 = o1;
                        end
                        done = 1;
                        state = st6;
                    end
                default:;
                endcase                              
    end
            
endmodule
