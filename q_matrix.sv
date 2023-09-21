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
bit [1:0] count,count_i,count_j,i,j;
logic signed [(2*SIZE)-1:0] A,B,C,D,E,F,G,H,J,K,L,M,N,O,P,U,R,S;
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
        count<=0;
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
        case(count)
        2'b00:begin
            A<=($signed(Cos[0]) * $signed(Cos[1]))>>>12;///////1,1
            B<=($signed(Cos[2]) * $signed(Sin[0]))>>>12;
            C<=($signed(Cos[0]) * $signed(Sin[1]))>>>12;
            F<=($signed(Sin[0]) * $signed(Sin[2]))>>>12;
            J<= -(($signed(Cos[1]) * $signed(Sin[0]))>>>12);//1,2
            K<=($signed(Cos[0]) * $signed(Cos[2]))>>>12;
            M<=($signed(Cos[0]) * $signed(Sin[2]))>>>12;
            N<=($signed(Cos[2]) * $signed(Sin[0]))>>>12;
            R<= -(($signed(Cos[1]) * $signed(Sin[2]))>>>12);//2,3
            S<=($signed(Cos[1]) * $signed(Cos[2]))>>>12;//3,3


/////////////////////////////////////////////////////////////////////////////////
            count<= count + 1;
        end
        2'b01:begin
            D<= ($signed(C[15:0]) * $signed(Sin[2]) )>>>12;
            G<= ($signed(C[15:0]) * $signed(Cos[2]) )>>>12;
            L<= ($signed(F[15:0]) * $signed(Sin[1]) )>>>12;
            P<= ($signed(N[15:0]) * $signed(Sin[1]) )>>>12;





            //////////////////////////////////////////
            count <= count + 1;
        end
        2'b10:begin
            E<= B[15:0] - D[15:0];//2,1
            H<= F[15:0] + G[15:0];//3,1
            O<= K[15:0] + L[15:0];//2,2
            U<= M[15:0] - P[15:0];//3,2
            ///-Sin[1]; 1,3

            ///////////////////////////////////////////////////////
            count <= count +1; 
        end
        2'b11:begin
            mat[0][0]<= A[15:0];
            mat[0][1]<= J[15:0];
            mat[0][2]<= -Sin[1];
            mat[1][0]<= E[15:0];
            mat[1][1]<= O[15:0];
            mat[1][2]<= R[15:0];
            mat[2][0]<= H[15:0];
            mat[2][1]<= U[15:0];
            mat[2][2]<= S[15:0];
            done<=1;
            count_i<=0;
            count_j<=0;
            finish<=0;
            Q<=0;
        end
        endcase 
    end
    else if(read)begin
        count<=0;
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