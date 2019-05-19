`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/05/02 22:09:07
// Design Name: 
// Module Name: DDU
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module DDU(
    input   cont,
    input   step,
    input   mem,
    input   inc,
    input   dec,
    input   [7:0]pc,
    input   clk, 
    input   rst,
    output  [7:0]addr,
    output  [7:0]addr_led,
    output  [7:0]pc_led,
    input   [31:0]reg_data,
    input   [31:0]mem_data,
    output  [7:0]an,
    output  [6:0]seg,
    output  reg run,
    input   clk2
    );
    
    wire    [31:0]d;
    reg     [3:0]data;
    
    reg    [7:0]addr_rf, addr_mem;
    reg     [15:0]display;
    
    reg    [3:0]rs, next_rs;
    
    always @(negedge clk2 or posedge rst)
    begin
        if(rst)
            rs <= 0;
        else
            rs <= next_rs;
    end
           
    always @(*)
    begin
       case(rs)
           0:begin
               if(cont == 1)
                   next_rs = 0;
               else
                   next_rs = 1;
           end
           1:begin
               if(cont == 1)
                   next_rs = 0;
               else if(step == 0)
                   next_rs = 1;
               else
                   next_rs = 2;
           end
           2:next_rs = 3;
           3:begin
               if(step == 1)
                   next_rs = 3;
               else
                   next_rs = 1;
           end
           default:next_rs = 0;
       endcase
    end               
    
    always @(rs)
    begin
       case(rs)
           0:run = 1;
           1:run = 0;
           2:run = 1;
           3:run = 0;
           default:run = 1;
       endcase
    end

    assign  d = (mem == 1) ? mem_data : reg_data;
    assign  pc_led = pc[7:0];
    assign  addr_led = addr;
    assign  an = display[7:0];
    assign  seg = display[15:9];
    
    assign  addr = (mem == 1) ? addr_mem[7:0] : addr_rf[7:0];

    reg     [3:0] state;
    reg     [2:0] ctrl;
    reg     [2:0] next_ctrl;
    reg     [4:0] rfad_next;
    reg     [7:0] memad_next;
    
    parameter   s0 = 4'd0, 
                s1 = 4'd1, 
                s2 = 4'd2, 
                s3 = 4'd3,
                s4 = 4'd4, 
                s5 = 4'd5, 
                s6 = 4'd6, 
                s7 = 4'd7,
                start = 4'd8;
    
    integer k = 0;
    
    always @(posedge clk2 or posedge rst)
    begin
        if(rst)
            ctrl <= 0;
        else
            ctrl <= next_ctrl;
    end
       
    always @(*)
    begin
        case(ctrl)
            0:case ({inc,dec})
                2'b10:next_ctrl = 1;
                2'b01:next_ctrl = 2;
                default :next_ctrl = 0;
            endcase
            1:next_ctrl = 3;
            2:next_ctrl = 4;
            3:case ({inc,dec})
                2'b00:next_ctrl <= 0;
                default :next_ctrl <= 3;
            endcase
            4:case ({inc,dec})
                2'b00:next_ctrl <= 0;
                default :next_ctrl <= 4;
            endcase
            default:next_ctrl = 0;
        endcase
    end            
    
    always @(posedge clk2 or posedge rst)
    begin
        if(rst)
        begin
            addr_rf <= 0;
            addr_mem <= 0;
        end
        else
            case(ctrl)
                1:begin
                    addr_mem <= (mem) ? addr_mem + 1'b1 : addr_mem;
                    addr_rf <= (mem == 0) ? addr_rf + 1'b1 : addr_rf;
                end
                2:begin
                    addr_mem <= (mem) ? addr_mem - 1'b1 : addr_mem;
                    addr_rf <= (mem == 0) ? addr_rf - 1'b1 : addr_rf;
                end
                default:;
            endcase
    end

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
                data = d[3:0];
                end
            s1: 
            begin
                display[7:0] = 8'b1111_1101;
                data = d[7:4];
                end
            s2: 
            begin
                display[7:0] = 8'b1111_1011;
                data = d[11:8];
                end
            s3: 
            begin
                display[7:0] = 8'b1111_0111;
                data = d[15:12];
                end
            s4: 
            begin
                display[7:0] = 8'b1110_1111;
                data = d[19:16];
                end
            s5: 
            begin
                display[7:0] = 8'b1101_1111;
                data = d[23:20];
                end
            s6: 
            begin
                display[7:0] = 8'b1011_1111;
                data = d[27:24];
                end
            s7: 
            begin
                display[7:0] = 8'b0111_1111;
                data = d[31:28];
                end
            default:;
        endcase
    end
   
    always @(state)
    begin
        display[8] = 1;
        case(data)
            4'h0: display[15:9] = 7'b1000_000;
            4'h1: display[15:9] = 7'b1111_001;
            4'h2: display[15:9] = 7'b0100_100;
            4'h3: display[15:9] = 7'b0110_000;
            4'h4: display[15:9] = 7'b0011_001;
            4'h5: display[15:9] = 7'b0010_010;
            4'h6: display[15:9] = 7'b0000_010;
            4'h7: display[15:9] = 7'b1111_000;
            4'h8: display[15:9] = 7'b0000_000;
            4'h9: display[15:9] = 7'b0010_000;
            4'ha: display[15:9] = 7'b0001_000;
            4'hb: display[15:9] = 7'b0000_011;
            4'hc: display[15:9] = 7'b1000_110;
            4'hd: display[15:9] = 7'b0100_001;
            4'he: display[15:9] = 7'b0000_110;
            4'hf: display[15:9] = 7'b0001_110;
            default:;
        endcase
    end
            
endmodule
