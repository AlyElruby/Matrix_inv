module MulMatrix #(parameter STG  = 12,parameter SIZE = 16,parameter INT  = 4,parameter FRAC = 12) 
  (
    input                              clk,
    input                              rst_n, 
    input                              write, 

    input logic signed [SIZE-1:0]      R_invElem,
    input logic signed [SIZE-1:0]      Q_TElem,
    input logic                        start_Mul, 
    input logic                        read_mul, 

    output logic                       QTxR_Dn_load,
    output logic                       Dn_out_Mul,
    output logic                       finish_Mul,

    output logic signed [SIZE-1:0]     QTxRInv_Elem
);

////**********************************************Internal Matrices*********************************************////

 logic [SIZE-1:0]      Q_matInternal    [0:2][0:2];        // Q_Transpose 3x3 matrix of 16-logic logic vectors

 logic [SIZE-1:0]      RInv_matInternal [0:2][0:2];        // R_inverse 3x3 matrix of 16-logic logic vectors

 logic [(SIZE*2)-1:0]  QTxRInv_Internal [0:2][0:2];       // (QR)inv 3x3 matrix of 16-logic logic vectors


////*********************************************elements calc**********************************************////

integer                                  I,J;
logic             [1:0]             wcount_i;
logic             [1:0]             wcount_j;
logic             [1:0]              count_i;
logic             [1:0]              count_j;


////*********************************************proc-block***********************************************////

always @(posedge clk or negedge rst_n) begin

    if (!rst_n) begin
      for (I = 0; I < 3 ; I++) begin                     // Reset the matrix to default values with nested for loop
        for (J =0; J < 3; J++) begin

            Q_matInternal    [I][J] <=0;
            RInv_matInternal [I][J] <=0;
            QTxRInv_Internal [I][J] <=0;

        end
      end
            count_i      <=0;
            count_j      <=0;
            wcount_j     <=0;
            wcount_i     <=0;
            QTxR_Dn_load <=0;
            Dn_out_Mul   <=0;
            finish_Mul   <=0;
            QTxRInv_Elem <=0;

  end else if(write) begin
  	    
            Q_matInternal    [wcount_i][wcount_j] <= Q_TElem;
            RInv_matInternal [wcount_i][wcount_j] <= R_invElem;
            QTxR_Dn_load                          <= 0;
             Dn_out_Mul                           <= 0;

         if ( (wcount_i == 2'b10) && (wcount_j == 2'b10) ) 

                    QTxR_Dn_load  <= 1;  

         if (wcount_j == 2'b10) begin

              wcount_j <='b0;
              wcount_i <= wcount_i+1;

      end else 
              wcount_j <= wcount_j+1;
              
            
  end else if (start_Mul) begin

  	    QTxRInv_Internal[0][0]  <= $signed(Q_matInternal[0][0]) * $signed(RInv_matInternal[0][0]) + $signed(Q_matInternal[1][0]) * $signed(RInv_matInternal[0][1]) +$signed(Q_matInternal[2][0]) * $signed(RInv_matInternal[0][2])  ;

        QTxRInv_Internal[0][1]  <= $signed(Q_matInternal[0][1]) * $signed(RInv_matInternal[0][0]) + $signed(Q_matInternal[1][1]) * $signed(RInv_matInternal[0][1]) + $signed(Q_matInternal[2][1]) * $signed(RInv_matInternal[0][2]) ;

        QTxRInv_Internal[0][2]  <= $signed(Q_matInternal[0][2]) * $signed(RInv_matInternal[0][0]) + $signed(Q_matInternal[1][2]) * $signed(RInv_matInternal[0][1]) + $signed(Q_matInternal[2][2]) * $signed(RInv_matInternal[0][2]);


        QTxRInv_Internal[1][0]  <= $signed(Q_matInternal[1][0]) * $signed(RInv_matInternal[1][1]) +  $signed(Q_matInternal[2][0]) * $signed(RInv_matInternal[1][2]) ;

        QTxRInv_Internal[1][1]  <= $signed(Q_matInternal[1][1]) * $signed(RInv_matInternal[1][1]) + $signed(Q_matInternal[2][1]) * $signed(RInv_matInternal[1][2]);

        QTxRInv_Internal[1][2]  <= $signed(Q_matInternal[1][2]) * $signed(RInv_matInternal[1][1]) + $signed(Q_matInternal[2][2]) * $signed(RInv_matInternal[1][2]);


        QTxRInv_Internal[2][0]  <= $signed(Q_matInternal[2][0]) * $signed(RInv_matInternal[2][2]);

        QTxRInv_Internal[2][1]  <= $signed(Q_matInternal[2][1]) * $signed(RInv_matInternal[2][2]); 

        QTxRInv_Internal[2][2]  <= $signed(Q_matInternal[2][2]) * $signed(RInv_matInternal[2][2]); 

        Dn_out_Mul              <= 1; 

   end else if (read_mul) begin

     if(!finish_Mul) begin

                QTxRInv_Elem <= (QTxRInv_Internal[count_i][count_j]) >>> 12;

   if ( (count_i == 2'b10 ) && (count_j == 2'b10) ) begin

                finish_Mul <= 1;
                

      end else if(count_j==2'b10) begin

                    count_i <=count_i+1;
                    count_j <='b0;

      end else begin

                    count_j <=count_j+1;    
      end

     end 
  end
      
  end

endmodule 