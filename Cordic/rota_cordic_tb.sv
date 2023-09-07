`timescale 1ns/1ps
module rot_cordic_tb #(parameter STG  = 12,parameter SIZE = 16,parameter INT  = 4,parameter FRAC = 12) ();
    reg                                 clk_tb;
    reg                               rst_n_tb;
    reg                               start_tb;  
    reg     signed [SIZE-1:0]           Xin_tb;
    reg     signed [SIZE-1:0]           Yin_tb;
    reg     signed [SIZE-1:0]         angle_tb;
    wire    signed [SIZE-1:0]          Xout_tb;
    wire    signed [SIZE-1:0]          Yout_tb;
    wire                               done_tb;
//Initial 
initial
 begin
initialize () ;                            //initialization
reset      () ; 
  angle_tb   = 16'h0C90;
  Xin_tb     = 16'h1000;
  Yin_tb     =  0;
start () ;
while(!done_tb)
    @(posedge clk_tb);
$display("xout = %0h yout = %0h ",Xout_tb,Yout_tb);
  angle_tb   = 16'h1921;
  Xin_tb     = 16'h1000;
  Yin_tb     =  0;
start() ;
while(!done_tb)
    @(posedge clk_tb);
$display("xout = %0h yout = %0h ",Xout_tb,Yout_tb);
angle_tb   = 16'h0800;
  Xin_tb     = 16'h1000;
  Yin_tb     =  0;
start() ;
while(!done_tb)
    @(posedge clk_tb);
$display("xout = %0h yout = %0h ",Xout_tb,Yout_tb);
angle_tb   = 16'h0000;
  Xin_tb     = 16'h1000;
  Yin_tb     =  0;
start() ;
while(!done_tb)
    @(posedge clk_tb);
$display("xout = %0h yout = %0h ",Xout_tb,Yout_tb);

repeat(1000)@(negedge clk_tb) $stop ;

end

////**********************************************TASKS*********************************************************////

/////////////// Signals Initialization //////////////////

task initialize ;
 begin
  clk_tb        = 1'b0 ; 
 end
endtask

///////////////start //////////////////

task start() ;
 begin
   @(posedge clk_tb);
  start_tb   = 1'b1 ;
    @(posedge clk_tb);
  start_tb   = 1'b0 ; 
  end

endtask
///////////////////////// RESET /////////////////////////

task reset ;
 begin
   rst_n_tb = 1'b1  ;             // rst is deactivated
 @(negedge clk_tb);
   rst_n_tb = 1'b0  ;            // rst is activated
   rst_n_tb = 1'b1  ; 
 end
endtask



////***********************************************Clock Generator*********************************************************////
always #5 clk_tb = ~clk_tb ;

////***********************************************DUT Instantation*********************************************************////
rot_cordic DUT (
   .clk(clk_tb),
   .rst_n(rst_n_tb),
   .start(start_tb),  
   .Xin(Xin_tb),
   .Yin(Yin_tb),
   .angle(angle_tb),
   .Xout(Xout_tb),
   .Yout(Yout_tb),
   .done(done_tb)
);



endmodule