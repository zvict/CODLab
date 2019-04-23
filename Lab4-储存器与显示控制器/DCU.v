`timescale 1ns / 1ps

module DCU1(
	input clk,            // 50MHz
	input rst,
  input [7:0] x,
  input [7:0] y,
    
	output [7:0] x_addr,
	output [7:0] y_addr,
	input [11:0] color,   // BGR
	output [3:0] vgaRed,
	output [3:0] vgaGreen,
	output [3:0] vgaBlue,
	output vgaHsync,
	output vgaVsync
	);


	// 800x600@72Hz
	parameter CLKF = 50;      // clock frequency
	parameter H_SYNC = 120;    // horizontal sync pulse
	parameter H_BEGIN = 456;  // horizontal data begin
	parameter H_END = 711;    // horizontal data end
	parameter H_PERIOD = 1040; // horizontal whole line length
	parameter V_SYNC = 6;     // vertical sync pulse
	parameter V_BEGIN = 201;   // vertical data begin
	parameter V_END = 456;    // vertical data end
	parameter V_PERIOD = 666; // vertical whole frame length
	
	wire clk25;
	wire vgaclk;
	counter16 clk25c(clk, rst, 2, clk25);
	assign vgaclk = (CLKF == 50) ? clk : clk25;

	wire [10:0] hcount;
	counter16 hc(vgaclk, rst, H_PERIOD, hcount);
	assign vgaHsync = (hcount < H_SYNC) ? 0 : 1;
	assign y_addr = hcount - H_BEGIN;

	wire [9:0] vcount;
	counter16 vc(~(hcount[10]), rst, V_PERIOD, vcount);
	assign vgaVsync = (vcount < V_SYNC) ? 0 : 1;
	assign x_addr = vcount - V_BEGIN;

	wire de;
	assign de = (vcount >= V_BEGIN) && (vcount < V_END) && (hcount >= H_BEGIN) && (hcount < H_END);
	wire cross;
	assign cross = ~(((vcount >= V_BEGIN + x - 5) && (vcount <= V_BEGIN + x + 5) && (hcount == H_BEGIN + y)) || ((hcount >= H_BEGIN + y - 5) && (hcount <= H_BEGIN + y + 5) && (vcount == V_BEGIN + x)));
	assign vgaRed = (de && cross) ? color[3:0] : 0;
	assign vgaGreen = (de && cross) ? color[7:4] : 0;
	assign vgaBlue = (de && cross) ? color[11:8] : 0;

endmodule

module counter16(
	input clk,             
	input rst,             
	input [15:0] range,
	output reg [15:0] value
);

    always @(posedge clk or posedge rst)
    begin
        if (rst) value <= 0;
        else if (value == range - 1) value <= 0;
        else value <= value + 1;
    end

endmodule
