`timescale 1ns / 1ps

module RegFile(clk,rst,we,ra0,ra1,wa,wd,rd0,rd1);
    parameter ADDR = 5;//寄存器编码/地址位宽
    parameter NUMB = 16;//寄存器个数
    parameter SIZE = 5;//寄存器数据位宽
    
    input clk;
    input rst;
    input we;
    input [ADDR:0]ra0;
    input [ADDR:0]ra1;
    input [ADDR:0]wa;
    input [SIZE:0]wd;
    
    output [SIZE:0]rd0;
    output [SIZE:0]rd1;
    
    reg [SIZE:0]REG_Files[0:NUMB-1];
    integer i;
        
    always@(posedge clk or posedge rst)
    begin
        if(rst)
            for(i = 0;i < NUMB;i = i + 1) 
                REG_Files[i] <= 0;
        else
            if(~we) 
                REG_Files[wa] <= wd;
    end
    
    assign rd0 = REG_Files[ra0];
    assign rd1 = REG_Files[ra1];
    
endmodule
