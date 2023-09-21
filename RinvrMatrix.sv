module RinvrMatrix #(parameter STG  = 12,parameter SIZE = 16,parameter INT  = 4,parameter FRAC = 12) 
  (
    input                                        clk,
    input                                      rst_n, 
    input                                      start, 
    input  logic                           Rinv_Read, 

//diagonal(input to cordic)
    input logic signed [SIZE-1:0]             RIn_00,
    input logic signed [SIZE-1:0]             RIn_11,
    input logic signed [SIZE-1:0]             RIn_22,

//upper
    input logic signed [SIZE-1:0]             RIn_01,
    input logic signed [SIZE-1:0]             RIn_02,
    input logic signed [SIZE-1:0]             RIn_12,

    output logic                         Rinv_Finish,
    output logic                     Rinv_Mat_DnLoad,
    output logic signed [SIZE-1:0]         R_invElem              //output is one element each clk cylce
);

////***********************************************Internal register*************************************************////

 logic [SIZE-1:0] matrix_internal [0:2][0:2];        // 3x3 matrix of 16-logic logic vectors

////*********************************************output from cordic********************************************////
        
  logic   signed [SIZE-1:0]         RInv_00;
  logic   signed [SIZE-1:0]         RInv_11;
  logic   signed [SIZE-1:0]         RInv_22;

////*********************************************elements calc************************************************////

  logic   signed [SIZE-1:0]         Rcalc_01;
  logic   signed [SIZE-1:0]         Rcalc_02;
  logic   signed [SIZE-1:0]         Rcalc_12;
  logic   signed [SIZE-1:0]         R_invElem_reg;
////*********************************************internal signals************************************************////

 integer                                     i;
 integer                                     j;

  // Counters
  logic        [1:0]                   count_i;
  logic        [1:0]                   count_j;
  logic        [2:0]                   shift_en;

  logic                                   done1;
  logic                                   done2;
  logic                                   done3;
  logic                           Rinv_Dn_calc ;

  logic  signed  [(3*SIZE)-1:0]         Rmul_01;                    
  logic  signed  [(3*SIZE)-1:0]         Rmul_12;
  logic  signed  [(5*SIZE)-1:0]       Rmul_02_1;
  logic  signed  [(3*SIZE)-1:0]      Rmul_02_48;
  logic  signed  [SIZE-1:0]         Rmul_02_fin;           //after subtraction final 02 

logic  signed  [(2*SIZE)-1:0]        Rmul_01_com;
logic  signed  [(2*SIZE)-1:0]        rmul_01_reg;

logic  signed  [(2*SIZE)-1:0]        Rmul_12_com;
logic  signed  [(2*SIZE)-1:0]        rmul_12_reg;

logic  signed  [(2*SIZE)-1:0]        Rmul_02_1_com;
logic  signed  [(2*SIZE)-1:0]        rmul_02_1_reg;

logic  signed  [(2*SIZE)-1:0]        Rmul_02_48_com;
logic  signed  [(2*SIZE)-1:0]        rmul_02_48_reg;

logic  signed  [(2*SIZE)-1:0]        Rmul_12_Mreg;

////*********************************************CORDIC Instant***********************************************////

 CustomVect r00 (.clk(clk),.rst_n(rst_n),.RInv(RInv_00),.RIn(RIn_00),.done(done1),.start(start));

 CustomVect r11 (.clk(clk),.rst_n(rst_n),.RInv(RInv_11),.RIn(RIn_11),.done(done2),.start(start));

 CustomVect r22 (.clk(clk),.rst_n(rst_n),.RInv(RInv_22),.RIn(RIn_22),.done(done3),.start(start));


////*********************************************enable signal************************************************////
logic                              RInv_Enable;

assign RInv_Enable = (done1 && done2 && done3);
 
////*********************************************proc-block***********************************************////

  always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin                               
      
       for (i = 0; i < 3 ; i++) begin                     // Reset the matrix to default values with nested for loop
        for (j =0; j < 3; j++) begin

            matrix_internal[i][j] <= 16'h0000;
      end
          end
             Rcalc_01      <= 0;
             Rcalc_12      <= 0;
             Rcalc_02      <= 0;
             R_invElem_reg <='h0000;
             Rinv_Finish   <= 0;
             Rinv_Dn_calc  <= 0;
             count_i       <= 0;
             count_j       <= 0;
             Rinv_Mat_DnLoad  <= 0;
             rmul_01_reg<=0;

    end else if(shift_en[0]) begin      // Update the matrix with input values

         Rcalc_01        <= Rmul_01;
         Rcalc_12        <= Rmul_12;
         Rcalc_02        <= Rmul_02_fin; 
         Rinv_Dn_calc    <=1; 

         Rinv_Mat_DnLoad <=0;
         Rinv_Finish     <=0;
         count_i         <=0;
         count_j         <=0;
         R_invElem_reg   <=0;

 end else if (Rinv_Dn_calc ) begin

        matrix_internal[0][0]  <= RInv_00 ;
        matrix_internal[0][1]  <= -Rcalc_01;
        matrix_internal[0][2]  <= Rcalc_02;
        matrix_internal[1][0]  <= 16'h0000;
        matrix_internal[1][1]  <= RInv_11 ;
        matrix_internal[1][2]  <= -Rcalc_12;
        matrix_internal[2][0]  <= 16'h0000;
        matrix_internal[2][1]  <= 16'h0000;        
        matrix_internal[2][2]  <= RInv_22 ;

        Rinv_Mat_DnLoad        <= 1;
        Rinv_Dn_calc           <= 0;
        Rinv_Finish            <= 0;
        Rinv_Dn_calc           <= 0;
        count_i                <= 0;
        count_j                <= 0;
        R_invElem_reg          <= 0;


    end else if (Rinv_Read) begin

     if(!Rinv_Finish) begin

               R_invElem_reg <= matrix_internal[count_i][count_j];

   if ( (count_i == 2'b10 ) && (count_j == 2'b10) ) begin

                Rinv_Finish <= 1;
                

      end else if(count_j==2'b10) begin

                    count_i <=count_i+1;
                    count_j <='0;

      end else begin

                    count_j <=count_j+1;    
      end

     end 
  end
      
  end




 /////***********************************************assigning************************************************/////

 
  assign R_invElem        = R_invElem_reg;

  assign Rmul_01_com      = ($signed((RIn_01))        * $signed((RInv_11))   >>> 12);

  assign Rmul_01          = ($signed((rmul_01_reg))   * $signed((RInv_00))   >>> 12);


  assign Rmul_12_com      = ($signed((RIn_12))        * $signed((RInv_22)) ) >>> 12;

  assign Rmul_12          = ($signed((rmul_12_reg))   * $signed((RInv_11)) ) >>> 12;

  assign Rmul_02_1_com    = (($signed( Rmul_12_Mreg)   * $signed(RIn_01))) >>> 12;

  assign Rmul_02_1        = ( $signed(rmul_02_1_reg)   * $signed(RInv_00)) >>> 12;

  assign Rmul_02_48_com   = ($signed(RIn_02)         * $signed(RInv_22)) >>> 12;

  assign Rmul_02_48       = ($signed(rmul_02_48_reg) * $signed(RInv_00)) >>> 12;

  assign Rmul_02_fin      =  Rmul_02_1[15:0]  -  Rmul_02_48[15:0] ; 


   always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin  

           rmul_01_reg    <= 0;
           rmul_12_reg    <= 0;
           rmul_02_1_reg  <= 0;
           Rmul_12_Mreg   <= 0;
           rmul_02_48_reg <= 0;
           shift_en       <= 0;
      end
      else begin
        shift_en       <= {RInv_Enable,shift_en[2:1]};
        rmul_01_reg    <= Rmul_01_com;
        rmul_12_reg    <= Rmul_12_com;
        rmul_02_1_reg  <= Rmul_02_1_com;
        Rmul_12_Mreg   <= Rmul_12;
        rmul_02_48_reg <= Rmul_02_48_com;
      end
    end           

endmodule

