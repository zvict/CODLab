module DIV(x,y,q,r,rst,clk,error,done);
    
    input   [3:0] x,y;
    input   clk,rst;
    output  reg [3:0] q,r;
    output  reg error,done;
    
    wire    [4:0] xout,yout;
    reg     [4:0] xt,yt;
    reg     [3:0] count;
    reg     [3:0] temp;
    wire    flag;
    reg     [2:0] state;
    
    parameter op1 = 3'b101,
                op2 = 3'b110;
    
    parameter st0 = 2'b00,
                st1 = 2'b01,
                st2 = 2'b10;
    
    ALU minus (
        .OP(op1),
        .A(xt),
        .B(yt),
        .F(xout)
        );
        
    ALU shift (
        .OP(op2),
        .A(1),
        .B(yt),
        .F(yout)
        );
        

    assign flag = (xt >= yt) ? 1 : 0;
        
    always @ (posedge clk or posedge rst)
    begin
        if(rst)
        begin
            xt <= {1'b0,x};
            yt <= {1'b0,y};
            count <= 0;
            error <= 0;
            done <= 0;
            temp <= y;
            state <= st0;
            q <= 0;
            r <= 0;
        end
        else if(y == 0)
            error <= 1;
        else
            case(state)
                st0:begin
                        if(flag)
                        begin
                            temp <= yt;
                            q <= q + (q == 0 ? 1 : q);
                            yt <= yout;
                            state <= st0;
                        end
                        else
                        begin
                            xt <= xt - temp;
                            yt <= y;
                            state <= st1;
                        end
                    end
                st1:begin
                        if(flag)
                        begin
                            xt <= xout;
                            q <= q + 1;
                            state <= st1;
                        end
                        else
                            state <= st2;
                    end
                st2:begin
                        r <= xt;
                        done <= 1;
                    end
            endcase
    end            

endmodule
