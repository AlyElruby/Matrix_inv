module CustomVect #(parameter STG  = 12,parameter SIZE = 16,parameter INT  = 4,parameter FRAC = 12) 
 ( 
    input                                     clk,
    input                                   rst_n,
    input                                   start,  
    input          signed [SIZE-1:0]          RIn, 
    output logic   signed [SIZE-1:0]         RInv,
    output logic                             done
);
////***********************************************REGISTERS*********************************************************////

logic  signed     [SIZE-1:0]    X_reg;
logic  signed     [SIZE-1:0]    Y_reg;
logic  signed     [SIZE-1:0] RInv_reg;
logic  signed     [SIZE-1:0]  X_shift;
logic                         Y_sign;
logic            [3:0]     itr_count;
 
////****************************************************proc-block************************************************************////

always @(posedge clk , negedge rst_n) begin
  if(!rst_n)begin
   
    itr_count <=0;
    done      <=0;
    X_reg     <=0;
    Y_reg     <=0;
    RInv_reg  <=0;
    itr_count <= STG;
 
end  else if(start) begin
    X_reg  <=   RIn;
    Y_reg  <=16'h1000;
itr_count  <=    0;
    done   <=    0;
 RInv_reg  <=    0;

end else begin
    done <=0;

    if(itr_count != STG) begin
      Y_reg <= Y_sign ? Y_reg  + X_shift : Y_reg - X_shift;
   RInv_reg <= Y_sign ? RInv_reg - (16'h1000>>>itr_count) : RInv_reg + (16'h1000>>>itr_count);

            if(itr_count == STG-1) begin
                     done <=   1;
                itr_count <= STG;

          end else begin
                itr_count <= itr_count +1;
                done <= 0;
            end
    end
  end
end
/////****************************************************assigning****************************************************/////
  assign X_shift    = X_reg>>>itr_count;                 //signed shift right
  assign Y_sign     = Y_reg[SIZE-1];                     //y_sign=1 if yreg[i]<0
  assign RInv       = RInv_reg;
endmodule