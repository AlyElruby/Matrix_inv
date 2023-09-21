module matrix_inv #(parameter STG  = 12,parameter SIZE = 16,parameter INT  = 4,parameter FRAC = 12) 
 (
    input clk,rst_n,start, read,
    output logic signed [SIZE -1 : 0] data_out,
    output logic done , finish
);
    /*'
    donot forget to connect rst_n and clk to all blocks
    and angle_i_rcord is input to all rot cordic
    */
    ////////////////////////////////////////////////declerations//////////////////////
    enum bit[3:0] {IDLE,LOAD,VECT,ROT,LOINV,INV,PREMUL,MULT,DN} state; //our states 
    bit [SIZE - 1 : 0] mat [0:2][0:2];//intial matrix to calculate it's inverse
    logic start_i_vcord , start_i_rcord , start_i_inv,start_i_q, start_i_mult;//wiring for all start signals for each module
    logic done_o_vcord,done_o_rcord, done_o_rcord1, done_o_rcord2, done_o_rcord3, done_o_inv, done_o_q, done_o_mult;//wiring for all done signals from each module
    logic write_i_mult;//signal to start to write inside internal registers in mult module
    logic read_i_q, read_i_inv, read_i_mult;//read signals to read from r_inv and Q modules
    logic load_i_q;//load signal to load(save) the sin and cos after each itr inside q_mat module to generate q mat later
    logic finish_o_q, finish_o_inv, finish_o_mult;//finish signal dedicates that the module finished from sending data.
    logic [SIZE - 1 : 0] X_i_rcord1 , Y_i_rcord1, X_i_rcord2 , Y_i_rcord2 ,X_i_rcord3 ,Y_i_rcord3;
    logic [SIZE - 1 : 0] X_o_rcord1 , Y_o_rcord1, X_o_rcord2 , Y_o_rcord2;//output signals from rot cordic modules 1 & 2
    logic [SIZE - 1 : 0] sin_o_rcord , cos_o_rcord, sin_i_q, cos_i_q;//sin and cos output from rcord3 and input to q_mat
    logic [SIZE - 1 : 0] X_i_vcord, Y_i_vcord;//data input to vector cordic
    logic [SIZE - 1 : 0] mag_o_vcord, angle_o_vcord , angle_i_rcord,angle_i_rcord_3;//magnitude and angle output from vcordic,this angle is input to rot cordic
    //logic [SIZE - 1 : 0] data_o_q , data_o_inv;//data output serially from q_mat and r_inv and input to mult module
    logic [SIZE - 1 : 0] s1,s2,s3,s4,s5,s6;//input signals to inv module
    logic [1:0] addr_i_q;//input address to q mat
    bit   [1:0] count ,i ,j;// internal counter
    logic loaded_o_mult;
    logic [SIZE - 1 : 0] Q , R ;////Q serial out from q mat and input for mult
    ////////////////////////////////////////////INTSTANTATIONS//////////////////////
    q_matrix q1 (
    clk,rst_n,start_i_q,load_i_q,read_i_q,
    addr_i_q,
    sin_i_q,cos_i_q,
    done_o_q,finish_o_q,
    Q
);
rot_cordic r1(
    clk,
    rst_n,
    start_i_rcord,  
    X_i_rcord1, 
    Y_i_rcord1,
    angle_i_rcord,
    X_o_rcord1,
    Y_o_rcord1,
    done_o_rcord1
);
rot_cordic r2(
    clk,
    rst_n,
    start_i_rcord,  
    X_i_rcord2, 
    Y_i_rcord2,
    angle_i_rcord,
    X_o_rcord2,
    Y_o_rcord2,
    done_o_rcord2
);
rot_cordic r3(
    clk,
    rst_n,
    start_i_rcord,  
    X_i_rcord3, 
    Y_i_rcord3,
    angle_i_rcord_3,
    cos_o_rcord,
    sin_o_rcord,
    done_o_rcord3
);
vect_cordic v1( 
    clk,
    rst_n,
    start_i_vcord,  
    X_i_vcord, 
    Y_i_vcord,
    mag_o_vcord,
    angle_o_vcord,
    done_o_vcord
);
RinvrMatrix i1(
    clk,
    rst_n, 
    start_i_inv, 
    read_i_inv, 
//diagonal(input to cordic)
    s1,
    s4,
    s6,
//upper
    s2,
    s3,
    s5,

    finish_o_inv,
    done_o_inv,
    R           //output is one element each clk cylce
);
MulMatrix mul1(
    clk,
    rst_n, 
    write_i_mult, 
    R,
    Q,
    start_i_mult, 
    read_i_mult, 
    loaded_o_mult,
    done_o_mult,
    finish_o_mult,
    data_out
);

    /////////////////////////////////////////////logic////////////////////////////////
    always @(posedge clk , negedge rst_n) begin
        if(!rst_n)begin
            mat[0][0]  <= 16'h2000;
            mat[0][1]  <= 16'h1000;
            mat[0][2]  <= 16'h0000;
            mat[1][0]  <= 16'h1000;
            mat[1][1]  <= 16'h2000;
            mat[1][2]  <= 16'h0000;
            mat[2][0]  <= 16'h1000;
            mat[2][1]  <= 16'h2000;        
            mat[2][2]  <= 16'h1000;
            done<=0;
            angle_i_rcord_3<=0;
            angle_i_rcord<=0;
            finish<=0;
            state<=IDLE;
            start_i_vcord<=0;
            start_i_rcord<=0;
            start_i_inv<=0;
            start_i_q<=0;
            start_i_mult<=0;
            read_i_q<=0;
            read_i_inv<=0;
            read_i_mult<=0;
            load_i_q<=0;
            sin_i_q<=0;
            cos_i_q<=0;
            write_i_mult<=0;
            count<=0;//itr count number
            s1<=0;
            s2<=0;
            s3<=0;
            s4<=0;
            s5<=0;
            s6<=0;
            addr_i_q<=0;
            X_i_rcord1<=0;
            X_i_rcord2<=0;
            X_i_rcord3<=0;
            Y_i_rcord1<=0;
            Y_i_rcord2<=0;
            Y_i_rcord3<=0;
            X_i_vcord<=0;
            Y_i_vcord<=0;
        end
        else begin
            load_i_q<=0;
            case(state)
                IDLE:begin
                    if(start) begin
                        state <= LOAD;
                        count <= 0;
                    end
                    else 
                        state <= IDLE;
                end
                LOAD:begin
                    load_i_q<=0;
                    case(count)
                            2'b00:begin
                                if(mat[1][0]==0)begin
                                    sin_i_q<=16'h0000;
                                    cos_i_q<=16'h1000;
                                    load_i_q<=1;
                                    addr_i_q<=count;
                                    count<=count+1;
                                    state<=LOAD;
                                end
                                else begin
                                    start_i_vcord<=1;
                                    X_i_vcord<=mat[0][0];
                                    Y_i_vcord<=mat[1][0];
                                    state<=VECT;
                                end
                            end
                            2'b01:begin
                                if(mat[2][0]==0)begin
                                    sin_i_q<=16'h0000;
                                    cos_i_q<=16'h1000;
                                    load_i_q<=1;
                                    addr_i_q<=count;
                                    count<=count+1;
                                    state<=LOAD;
                                end
                                else begin
                                    start_i_vcord<=1;
                                    X_i_vcord<=mat[0][0];
                                    Y_i_vcord<=mat[2][0];
                                    state<=VECT;
                                end
                            end
                            2'b10:begin
                                if(mat[2][1]==0)begin
                                    sin_i_q<=16'h0000;
                                    cos_i_q<=16'h1000;
                                    load_i_q<=1;
                                    addr_i_q<=count;
                                    count<=0;
                                    start_i_inv<=1;
                                    start_i_q<=1;
                                    state<=INV;
                                end
                                else begin
                                    start_i_vcord<=1;
                                    X_i_vcord<=mat[1][1];
                                    Y_i_vcord<=mat[2][1];
                                    state<=VECT;
                                end
                            end
                        endcase
                end
                VECT:begin
                    start_i_vcord<=0;
                    if(!done_o_vcord)
                        state<=VECT;
                    else begin
                        case(count)
                            2'b00:begin
                                mat[0][0]<=mag_o_vcord;
                                mat[1][0]<=16'h0000;
                                angle_i_rcord<=-angle_o_vcord;
                                angle_i_rcord_3<=-angle_o_vcord;
                                X_i_rcord1<= mat[0][1];
                                Y_i_rcord1<= mat[1][1];
                                X_i_rcord2<= mat[0][2];
                                Y_i_rcord2<= mat[1][2];
                                X_i_rcord3<= 16'h1000;
                                Y_i_rcord3<= 16'h0000;
                                start_i_rcord<= 1;
                                state<= ROT;
                            end
                            2'b01:begin
                                mat[0][0]<=mag_o_vcord;
                                mat[2][0]<=16'h0000;
                                angle_i_rcord<=-angle_o_vcord;
                                angle_i_rcord_3<=-angle_o_vcord;
                                X_i_rcord1<= mat[0][1];
                                Y_i_rcord1<= mat[2][1];
                                X_i_rcord2<= mat[0][2];
                                Y_i_rcord2<= mat[2][2];
                                X_i_rcord3<= 16'h1000;
                                Y_i_rcord3<= 16'h0000;
                                start_i_rcord<= 1;
                                state<= ROT;
                            end
                            2'b10:begin
                                mat[1][1]<=mag_o_vcord;
                                mat[2][1]<=16'h0000;
                                angle_i_rcord<=-angle_o_vcord;
                                angle_i_rcord_3<=-angle_o_vcord;
                                X_i_rcord1<= mat[1][2];
                                Y_i_rcord1<= mat[2][2];
                                X_i_rcord2<= 16'h0000;
                                Y_i_rcord2<= 16'h0000;
                                X_i_rcord3<= 16'h1000;
                                Y_i_rcord3<= 16'h0000;
                                start_i_rcord<= 1;
                                state<= ROT;
                            end
                        endcase
                    end
                end
                ROT:begin
                    start_i_rcord<=0;
                    if(!done_o_rcord)
                        state<= ROT;
                    else begin
                        case(count)
                            2'b00:begin
                                mat[0][1]<=X_o_rcord1;
                                mat[1][1]<=Y_o_rcord1;
                                mat[0][2]<=X_o_rcord2;
                                mat[1][2]<=Y_o_rcord2;
                                sin_i_q<= sin_o_rcord;
                                cos_i_q<= cos_o_rcord;
                                load_i_q<=1;
                                state<= LOAD;
                                addr_i_q <=count;
                                count<=count+1;
                            end
                            2'b01:begin
                                mat[0][1]<=X_o_rcord1;
                                mat[2][1]<=Y_o_rcord1;
                                mat[0][2]<=X_o_rcord2;
                                mat[2][2]<=Y_o_rcord2;
                                sin_i_q<= sin_o_rcord;
                                cos_i_q<= cos_o_rcord;
                                load_i_q<=1;
                                state<= LOAD;
                                addr_i_q<=count;
                                count<=count+1;
                            end
                            2'b10:begin
                                mat[1][2]<=X_o_rcord1;
                                mat[2][2]<=Y_o_rcord1;
                                sin_i_q<= sin_o_rcord;
                                cos_i_q<= cos_o_rcord;
                                load_i_q<=1;
                                state<= LOINV;
                                addr_i_q<=count;
                                count<=0;
                            end
                        endcase
                    end
                end
                LOINV:begin
                    load_i_q<=0;
                    start_i_inv<=1;
                    start_i_q<=1;
                    s1<=mat[0][0];
                    s2<=mat[0][1];
                    s3<=mat[0][2];
                    s4<=mat[1][1];
                    s5<=mat[1][2];
                    s6<=mat[2][2];
                    state<= INV;
                end
                INV:begin
                    start_i_inv<=0;
                    if(!(done_o_inv && done_o_q) )
                        state<=INV;
                    else begin
                        state<= PREMUL;
                        read_i_inv<=1;
                        read_i_q<=1;
                        start_i_q<=0;
                    end
                end
                PREMUL:begin
                    if(!(finish_o_inv && finish_o_q && loaded_o_mult))begin
                        write_i_mult <= 1;
                        read_i_inv<=1;
                        read_i_q<=1;
                        state <= PREMUL;
                    end
                    else begin
                        write_i_mult <= 0;
                        state <= MULT;
                        read_i_inv<=0;
                        read_i_q<=0;
                        start_i_mult<=1;
                    end
                end
                MULT:begin
                    start_i_mult<=0;
                    if(!done_o_mult)
                        state<= MULT;
                    else begin
                        done<=1;
                        state<=DN;
                    end
                end
                DN:begin
                    if(read && !(finish_o_mult))begin
                        read_i_mult<=1;
                        state<=DN;
                    end
                    else begin
                        finish<=1;
                        read_i_mult<=0;
                    end
                end
            endcase
        end
    end
    assign done_o_rcord = done_o_rcord1 & done_o_rcord2 & done_o_rcord3;
endmodule