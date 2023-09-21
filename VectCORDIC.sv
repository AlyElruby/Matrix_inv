module vect_cordic #(parameter STG  = 12,parameter SIZE = 16,parameter INT  = 4,parameter FRAC = 12) 
 ( 
    input                                          clk,
    input                                        rst_n,
    input                                        start,  
    input          signed [SIZE-1:0]          Vect_Xin, 
    input          signed [SIZE-1:0]          Vect_Yin,
    output  logic  signed [SIZE-1:0]        MagxFactor,
    output  logic  signed [SIZE-1:0]             theta,
    output  logic                                 done
);
////***********************************************REGISTERS*********************************************************////

logic   signed     [SIZE-1:0]        X_reg;
logic   signed     [SIZE-1:0]        Y_reg;
logic   signed     [SIZE:0]    theta_reg;
logic   signed     [SIZE:0]      X_shift;
logic   signed     [SIZE:0]      Y_shift;
//logic   signed     [SIZE-1:0]  factor;
logic   signed [(SIZE*2)-1 : 0]     Magmul;
logic                               Y_sign;
logic           [3:0]            itr_count;

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


////*********************************************proc-block******************************************************////

always @(posedge clk , negedge rst_n) begin
  if(!rst_n)begin
    X_reg     <=0;
    Y_reg     <=0;
    theta_reg <='h0;
    itr_count <=0;
    done      <=0;
    itr_count <= STG;
    //factor<=16'h09b8;

   end 
   else if(start) begin
    X_reg       <=  Vect_Xin;
    Y_reg       <=  Vect_Yin;
    theta_reg   <=  'h0;
    itr_count   <=    0;
    done        <=    0;

   end 
   else begin
    done <=0;
    if(itr_count != STG) begin
      X_reg     <= Y_sign ? X_reg - Y_shift : X_reg  +Y_shift;
      Y_reg     <= Y_sign ? Y_reg + X_shift : Y_reg - X_shift;
      theta_reg <= Y_sign ? theta_reg - atan_table[itr_count] : theta_reg + atan_table[itr_count];
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
/////*************************************************assigning****************************************************/////
  assign X_shift    = X_reg>>>itr_count;                 //signed shift right
  assign Y_shift    = Y_reg>>>itr_count;
  assign Y_sign     = Y_reg[SIZE-1];                     //y_sign=1 if yreg[i]<0
  assign theta      = theta_reg;
  assign Magmul     = ($signed(X_reg) * $signed(16'h09b8))>>>12;
  assign MagxFactor = Magmul ;
endmodule