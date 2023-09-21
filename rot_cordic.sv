module rot_cordic #(parameter STG  = 12,parameter SIZE = 16,parameter INT  = 4,parameter FRAC = 12) 
 (
    input                                clk,
    input                              rst_n,
    input                              start,  
    input     signed [SIZE-1:0]          Xin, 
    input     signed [SIZE-1:0]          Yin,
    input     signed [SIZE-1:0]        angle,
    output    logic  signed [SIZE-1:0]         Xout,
    output    logic  signed [SIZE-1:0]         Yout,
    output    logic                       done
);
////***********************************************REGISTERS*********************************************************////
logic   signed     [SIZE-1:0]    X_reg;
logic   signed     [SIZE-1:0]    Y_reg;
logic   signed     [SIZE-1:0]    theta;
logic   signed     [SIZE-1:0]  X_shift;
//logic   signed     [SIZE-1:0]  factor;
logic   signed     [SIZE-1:0]  Y_shift;
logic                       theta_sign;
logic              [3:0]     itr_count;
logic   signed [(SIZE*2)-1 : 0] X_mul ,Y_mul;
////***********************************************arctan table*********************************************************////
logic signed [SIZE-1:0] atan_table[0:14];
assign atan_table[00] = 16'h0c90; // 45.000 Radian -> atan(2^0)
assign atan_table[01] = 16'h076b; // 26.565 Radian -> atan(2^-1)
assign atan_table[02] = 16'h03EB;
assign atan_table[03] = 16'h01fd; // 14.036 Radian -> atan(2^-2)
assign atan_table[04] = 16'h00ff; // atan(2^-n)
assign atan_table[05] = 16'h007f;
assign atan_table[06] = 16'h003f;
assign atan_table[07] = 16'h001f;
assign atan_table[08] = 16'h000f;
assign atan_table[09] = 16'h0007;
assign atan_table[10] = 16'h0003;
assign atan_table[11] = 16'h0001;
////****************************************************proc-block************************************************************////
always @(posedge clk , negedge rst_n) begin
  if(!rst_n)begin
    X_reg     <=0;
    Y_reg     <=0;
    theta     <=0;
    done      <=0;
    itr_count <= STG;
    //factor<=16'h09b8;
   end 
   else if(start) begin
    X_reg       <=  Xin;
    Y_reg       <=  Yin;
    theta       <=angle;
    itr_count   <=    0;
    done        <=    0;
   end 
   else begin
    done <=0;
    if(itr_count != STG) begin
      X_reg <= theta_sign ? X_reg + Y_shift : X_reg - Y_shift;
      Y_reg <= theta_sign ? Y_reg - X_shift : Y_reg + X_shift;
      theta <= theta_sign ? theta + atan_table[itr_count] : theta - atan_table[itr_count];  
            if(itr_count == STG-1) begin
                done<=1;
                itr_count <= STG;
            end
            else begin
                itr_count <= itr_count +1;
                done <= 0;
            end
    end
  end
end
/////*************************************************************assigning****************************************************/////
always_comb begin 
  X_shift    = X_reg>>>itr_count;                 //signed shift right
  Y_shift    = Y_reg>>>itr_count;
  theta_sign =theta[SIZE-1];                     //theta_sign=1 if z[i]<0
  X_mul =    ($signed(X_reg) * $signed(16'h09b8))>>>12;
  Y_mul =    ($signed(Y_reg) * $signed(16'h09b8))>>>12;
  Xout       =  X_mul;
  Yout       =  Y_mul;
end
endmodule