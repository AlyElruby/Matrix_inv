module q_matrix #(parameter STG  = 12,parameter SIZE = 16,parameter INT  = 4,parameter FRAC = 12) (
    input clk,rst_n,start,load,read,
    input [1:0] addr,
    input signed [SIZE-1 : 0] sin,cos,
    output reg done,finish,
    output reg signed [SIZE-1 : 0] Q
);
bit signed [SIZE-1 : 0] mat [0:2] [0:2];
bit signed [SIZE-1 : 0] Sin [0:2];
bit signed [SIZE-1 : 0] Cos [0:2];
bit [1:0] count_i,count_j,i,j;
always@(posedge clk , negedge rst_n)begin
    if(!rst_n)begin
        for(i=0;i<3;i++)begin
            for(j=0;j<3;j++)
                mat[i][j]<=0;
        end
        foreach(Cos[i])begin
            Cos[i]<=0;
            Sin[i]<=0;
        end
        Q<=0;
        count_i<=0;
        count_j<=0;
        done<=0;
        finish<=0;
    end
    else if(load)begin
        Cos[addr] <= cos;
        Sin[addr] <= sin;
        done<=0;
        count_i<=0;
        count_j<=0;
        finish<=0;
        Q<=0;
    end
    else if(start) begin
        mat[0][0]<= Cos[0] *Cos[1];
        mat[0][1]<= -Sin[0] *Cos[1];
        mat[0][2]<= -Sin[1];
        mat[1][0]<= ((Cos[0] *Sin[1])+Sin[0])*Cos[2];
        mat[1][1]<= ((-Sin[0]*Sin[1])+Cos[0])*Sin[2];
        mat[1][2]<= (Cos[1]*Cos[2])-Sin[2];
        mat[2][0]<= ((Cos[0]*Sin[1])+Sin[0])*Sin[2];
        mat[2][1]<= ((-Sin[0]*Sin[1])+Cos[0])*Sin[2];
        mat[2][2]<= (Cos[1]*Cos[2])+Sin[2];
        done<=1;
        count_i<=0;
        count_j<=0;
        finish<=0;
        Q<=0;
    end
    else if(read)begin
        if(!finish)begin
            Q<=mat[count_i][count_j];
            if((count_i==2'b10)&&(count_j==2'b10))
                finish<=1;
            else if(count_j==2'b10)begin
                count_i<=count_i+1;
                count_j<='0;
            end
            else
                count_j<=count_j+1;
        end
    end
end
endmodule