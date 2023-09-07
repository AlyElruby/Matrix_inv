module q_tb#(parameter STG  = 12,parameter SIZE = 16,parameter INT  = 4,parameter FRAC = 12) ();
    logic  clk,rst_n,start,load,read;
    logic  [1:0] addr;
    logic  signed [SIZE-1 : 0] sin,cos;
    logic  done,finish;
    logic signed [SIZE-1 : 0] Q;
    q_matrix q1 (
    clk,rst_n,start,load,read,
    addr,
    sin,cos,
    done,finish,
    Q
);
always #5 clk = ~clk ;
initial begin
    initialize();
    reset();
    loading() ;
    starting() ;
    reading() ;
    #200;
    $stop();
end
///////////////////////initialize/////////////
    task initialize ;
    begin
    clk= 1'b0 ; 
    start=0;
    load=0;
    read=0;
    addr=0;
    sin=0;
    cos=0;
    end
    endtask
    ///////////////load////////////
    task loading() ;
    begin
    @(posedge clk);
    sin = $random() ;
    cos = $random() ;
    load = 1;
    repeat(2) begin
    @(posedge clk);
        sin = $random() ;
        cos = $random() ;
        load = 1;
        addr = addr+1;
    end
    load = 0;
    @(posedge clk);
    end

    endtask

    ///////////////start //////////////////

    task starting() ;
    begin
    @(posedge clk)
        start   = 1'b1 ;
    @(posedge clk);
    start   = 1'b0;
    @(posedge clk);
    if(done) 
        $display("pass Calculationa");
    else    
        $display("faild calculations");
    end

    endtask
    ///////////////////////// RESET /////////////////////////

    task reset ;
    begin
    rst_n = 1'b0  ;             // rst is deactivated
    @(posedge clk);            // rst is activated
    rst_n = 1'b1  ; 
    end
    endtask


    ///////////////read //////////////////
    task reading() ;
    begin
    @(negedge clk);
    read   = 1'b1 ;
    repeat(10)
        @(posedge clk);
    if(finish) 
        $display("pass reading");
    else    
        $display("faild reading");
    end

    endtask
endmodule