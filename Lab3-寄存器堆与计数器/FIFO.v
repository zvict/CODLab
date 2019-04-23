`define SRAM_SIZE 8
`timescale 1ns / 1ps

module FIFO(
    display,
    in_data,
    out_data,
    en_out,
    en_in,
    nfull,
    nempty,
    clk,
    rst);
    
    input   en_out,en_in,clk,rst;
    
    input   [3:0] in_data;
    output  [3:0] out_data;
    output  [15:0] display;
    reg     [3:0] in_data_buf, out_data_buf;
    
    output  reg nfull,nempty;
    
    /* RF */
    wire    rd,wr;    
    wire    [3:0] in_d, out_d;    
    
    reg     [5:0] fifo_wp, fifo_rp;
    
    reg     [5:0] fifo_wp_next, fifo_rp_next;
    
    reg     near_full, near_empty;
    
    reg   [3:0] state;
    
    //空满标志
    reg  flag [0:`SRAM_SIZE - 1];
    
    wire [5:0] dis_addr;
    wire [4:0] dis_data;
    
    parameter   idle = 'b0000,
                  read_ready = 'b0100,
                  read = 'b0101,
                  read_over = 'b0111,
                  write_ready = 'b1000,
                  write = 'b1001,
                  write_over = 'b1011;
                  
    RegFile RF (
        .clk(clk),
        .rst(rst),
        .we(wr),
        .wd(in_d),
        .rd0(out_d),
        .ra1(dis_addr),
        .rd1(dis_data),
        .wa(fifo_wp),
        .ra0(fifo_rp)
        );
        
    DIS dis (
        .flag(flag[dis_addr]),
        .addr(dis_addr),
        .data(dis_data),
        .rst(rst),
        .clk(clk),
        .head(fifo_rp),
        .display(display)
        );
              
    always @(posedge clk or posedge rst)
    begin
        if(rst)
        begin
            state <= idle;
            flag[0] <= 0;
            flag[1] <= 0;
            flag[2] <= 0;
            flag[3] <= 0;
            flag[4] <= 0;
            flag[5] <= 0;
            flag[6] <= 0;
            flag[7] <= 0;
            end
        else
            case(state)
                idle:
                    if(en_in == 0 && nfull)
                        state <= write_ready;
                    else if(en_out == 0 && nempty)
                        state <= read_ready;
                    else
                        state <= idle;
                        
                read_ready:
                    state <= read;
                
                read:
                    if(en_out == 1)
                        state <= read_over;
                    else
                        state <= read;
                
                read_over:
                    state <= idle;
                
                write_ready:
                    state <= write;
                
                write:
                    if(en_in == 1)
                        state <= write_over;
                    else
                        state <= write;
                        
                write_over:
                    state <= idle;
                    
                default:state <= idle;
            endcase
    end
    
    assign wr = (state == write) ? en_in : 1'b1;
    
    always @(posedge clk)
        if(~en_in)
        begin
            in_data_buf <= in_data;
            flag[fifo_wp] <= 1'b1;
        end
    
    assign in_d = (state[3]) ? in_data_buf : 4'b0000;
            
    assign out_data = (state[2]) ? out_data_buf : 4'b0000;
    
    always @(posedge clk)
        if(state == read)
        begin
            out_data_buf <= out_d;
            flag[fifo_rp] <= 0;
        end
    
    always @(posedge clk or posedge rst)
        if(rst)
            fifo_rp <= 0;
        else if(state == read_over)
            fifo_rp <= fifo_rp_next;
    
    always @(fifo_rp)
        if(fifo_rp == `SRAM_SIZE - 1)
            fifo_rp_next = 0;
        else
            fifo_rp_next = fifo_rp + 1;
    
    always @(posedge clk or posedge rst)
        if(rst)
            fifo_wp <= 0;
        else if(state == write_over)
            fifo_wp <= fifo_wp_next;
    
    always @(fifo_wp)
        if(fifo_wp == `SRAM_SIZE - 1)
            fifo_wp_next = 0;
        else
            fifo_wp_next = fifo_wp + 1;
    
    always @(posedge clk or posedge rst)
        if(rst)
            near_empty <= 1'b0;
        else if(fifo_wp == fifo_rp_next)
            near_empty <= 1'b1;
        else
            near_empty <= 1'b0;
    
    always @(posedge clk or posedge rst)
        if(rst)
            nempty <= 1'b0;
        else if(near_empty && state == read)
            nempty <= 1'b0;
        else if(state == write)
            nempty <= 1'b1;
        
    always @(posedge clk or posedge rst)
        if(rst)
            near_full <= 1'b0;
        else if(fifo_rp == fifo_wp_next)
            near_full <= 1'b1;
        else
            near_full <= 1'b0;
            
    always @(posedge clk or posedge rst)
        if(rst)
            nfull <= 1'b1;
        else if(near_full && state == write)
            nfull <= 1'b0;
        else if(state == read)
            nfull <= 1'b1;
                
endmodule
