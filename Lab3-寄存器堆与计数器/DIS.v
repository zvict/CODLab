`timescale 1ns / 1ps


/* ATTENTION */
/* 这个DIS模块不能有效显示出队列的情况，出队列后的元素仍然会被显示 */

module DIS(
    flag,
    display,
    head,
    clk,
    rst,
    addr,
    data
    );
    
    input   clk, rst;
    input   [3:0] head;
    
    input   flag;
        
    output  reg [15:0] display;
    
    reg     [3:0] state;
    parameter   s0 = 4'd0, s1 = 4'd1, s2 = 4'd2, s3 = 4'd3,
                    s4 = 4'd4, s5 = 4'd5, s6 = 4'd6, s7 = 4'd7, start = 4'd8;
                    
    output  reg     [5:0] addr;
    input   wire    [4:0] data;
    
    integer k = 0;
    
    always @(posedge clk or posedge rst)
    begin
        if(rst)
        begin
            k <= 0;
            state <= s0;
        end
        else
        begin
            k <= k + 1;
            if(k < 25000)
                state <= s0;
            else if(k < 50000)
                state <= s1;
            else if(k < 75000)
                state <= s2;
            else if(k < 100000)
                state <= s3;
            else if(k < 125000)
                state <= s4;
            else if(k < 150000)
                state <= s5;
            else if(k < 175000)
                state <= s6;
            else if(k < 200000)
                state <= s7;
            else if(k >= 200000)
                k <= 0;
        end
    end
    
    always @(*)
    begin
        case(state)
            s0: 
            begin
                display[7:0] = 8'b1111_1110;
                addr = 5'd0;
                end
            s1: 
            begin
                display[7:0] = 8'b1111_1101;
                addr = 5'd1;
                end
            s2: 
            begin
                display[7:0] = 8'b1111_1011;
                addr = 5'd2;
                end
            s3: 
            begin
                display[7:0] = 8'b1111_0111;
                addr = 5'd3;
                end
            s4: 
            begin
                display[7:0] = 8'b1110_1111;
                addr = 5'd4;
                end
            s5: 
            begin
                display[7:0] = 8'b1101_1111;
                addr = 5'd5;
                end
            s6: 
            begin
                display[7:0] = 8'b1011_1111;
                addr = 5'd6;
                end
            s7: 
            begin
                display[7:0] = 8'b0111_1111;
                addr = 5'd7;
                end
            default:;
        endcase
    end
   
    always @(state) //这里不能always @(*)，会出错
    begin
        if(flag == 1'b1)
            case(data)
                4'd0: display[15:9] = 7'b1000_000;
                4'd1: display[15:9] = 7'b1111_001;
                4'd2: display[15:9] = 7'b0100_100;
                4'd3: display[15:9] = 7'b0110_000;
                4'd4: display[15:9] = 7'b0011_001;
                4'd5: display[15:9] = 7'b0010_010;
                4'd6: display[15:9] = 7'b0000_010;
                4'd7: display[15:9] = 7'b1111_000;
                4'd8: display[15:9] = 7'b0000_000;
                4'd9: display[15:9] = 7'b0010_000;
                default:;
            endcase
        else
            display[15:9] = 7'b1111_111;
    end
    
    always @(*)
    begin
        if(state == head)
            display[8] = 0;
        else
            display[8] = 1;
    end    
            
endmodule
