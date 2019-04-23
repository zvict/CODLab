`timescale 1ns / 1ps

module PCU(
    input clk,
    input rst,
    input [3:0]dir,
    input draw,
    input [3:0]in_R,
    input [3:0]in_G,
    input [3:0]in_B,
    
    output [3:0]R,
    output [3:0]G,
    output [3:0]B,
    output VS,
    output HS
    );
    
    reg [7:0] x;
    reg [7:0] y;
    
    wire [11:0]color;
    wire [7:0]x_addr;
    wire [7:0]y_addr;
    
    wire clk_50;
    wire clk_10;
    
    assign addr = {x,y};
    assign COLOR = {in_R,in_G,in_B};
    assign we = draw;
    
    clk_wiz_0 clk50(
        .clk_in1(clk),
        .clk_out1(clk_50)
        );
    
    clk_wiz_1 clk10(
        .clk_in1(clk),
        .clk_out1(clk_10)
        );
        
    dist_mem_gen_0 mem(
        .a({x,y}),
        .d({in_R,in_G,in_B}),
        .clk(clk_10),
        .we(draw),
        .dpra({x_addr,y_addr}),
        .dpo(color)
        );
    
    DCU1 display(
        .clk(clk_50),
        .rst(rst),
        .x_addr(x_addr),
        .y_addr(y_addr),
        .x(x),
        .y(y),
        .vgaRed(R),
        .vgaGreen(G),
        .vgaBlue(B),
        .vgaHsync(HS),
        .vgaVsync(VS),
        .color(color)
        );  
            
    wire clk_2;
    reg [16:0]count_2;
    
    fdivision(rst,clk,clk_2);
    
    always @(posedge clk_2 or posedge rst)
    begin
        if(rst)
        begin
            x <= 8'd128;
            y <= 8'd128;
        end
        else
        begin
            case(dir)
                4'b0000: ;
                4'b0001:
                    x <= x + 1;
                4'b0010:
                    y <= y + 1;
                4'b0100:
                    x <= x - 1;
                4'b1000:
                    y <= y - 1;
                4'b0011:begin
                    x <= x + 1;
                    y <= y + 1;
                    end
                4'b1001:begin
                    x <= x + 1;
                    y <= y - 1;
                    end
                4'b0110:begin
                    x <= x - 1;
                    y <= y + 1;
                    end
                4'b1100:begin
                    x <= x - 1;
                    y <= y - 1;
                    end
                default: ;
            endcase
        end
    end
    
endmodule

module fdivision(
    input rst,
    input clk_in,
    output reg clk_out
    );

    reg [19:0] j;
    
    always @(posedge clk_in or posedge rst)
    begin
        if(rst)
        begin
            clk_out <= 0;
            j <= 0;
        end
        else
        begin
            if(j == 999999)
            begin
                j <= 0;
                clk_out <= ~clk_out;
                end
            else
                j <= j + 1;
        end
    end
endmodule
