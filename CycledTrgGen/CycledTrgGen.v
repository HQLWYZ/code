/*----------------------------------------------------------*/
/* 															*/
/*	file name:	CycledTrgGen.v			           			*/
/* 	date:		2025/03/07									*/
/* 	version:	v1.0										*/
/* 	author:		Wang Shen									*/
/* 	note:		IN LINE 47&48, different words for SIMULATION  or real application.	*/
/* 															*/
/*----------------------------------------------------------*/

module CycledTrgGen(
	input			clk_in,
	input			rst_in,
    input   [1:0]   cycled_trg_oe_in,//enable cycle trigger generator
    input           cycled_trg_bgn_in,
    input   [7:0]	cycled_trg_period_in,//the Unit = 2^17* 20 nano-second, approximately 2.621ms. So the maximum period is 2.621ms*2^8 = 1.34s
    input   [15:0]	cycled_trg_num_in,//////cycled trigger number
    output          cycled_trg_out,
    output          cycled_trg_end_out,//width = 1 clock
    output	        cycled_trg_1us_out////expanded pulse of the cycle trigger
	);
	


//register the output signal
reg  cycled_trg_end_sig, cycled_trg_1us_sig;

//cycled trigger 
reg cycled_trg_enb_r, cycled_trg_sig;///
reg[24:0]   cycled_trg_period_cnt;//the clk is 50Mhz
reg[15:0]   cycled_trg_cnt;
/////cycled_trg_oe_in = 2'b10: non-stop, to send the cycled trigger signal
///  cycled_trg_oe_in = 2'b01: just send the cycled signal when receiving the command,  within defined trigger number in.

reg cycled_trg_bgn_in_r;
always@(posedge clk_in or negedge rst_in)
    if(!rst_in)
        cycled_trg_bgn_in_r <= 1'b0;
    else
        cycled_trg_bgn_in_r <= cycled_trg_bgn_in; 


always @(posedge clk_in or negedge rst_in)
begin
    if (!rst_in) begin
        cycled_trg_period_cnt <= 25'b0;
        cycled_trg_sig <= 1'b0;
        cycled_trg_end_sig <= 1'b0;
        cycled_trg_cnt <= 16'b0;
        cycled_trg_enb_r <= 1'b0;
    end
    else if ( (cycled_trg_oe_in[1] == 1'b1) &  (cycled_trg_oe_in[0] == 1'b1) && cycled_trg_enb_r && (cycled_trg_cnt < cycled_trg_num_in) )  begin//
       if (cycled_trg_period_cnt >= {cycled_trg_period_in, 17'b0}) begin //the time step is 2 to 17th power
       //if (cycled_trg_period_cnt >= {cycled_trg_period_in, 2'b0}) begin //the time step is 2 to 2th power, ONLY FOR SIMULATION
            cycled_trg_period_cnt <= 25'b0;
            cycled_trg_sig <= 1'b1;//
            cycled_trg_cnt <= cycled_trg_cnt + 1;
        end
        else  begin
        	cycled_trg_period_cnt <= cycled_trg_period_cnt + 1;
        	cycled_trg_sig <= 1'b0;
        end
    end  
    else if ( (cycled_trg_oe_in[0] == 1'b1) & cycled_trg_enb_r & (cycled_trg_cnt >= cycled_trg_num_in) )  begin
        cycled_trg_end_sig <= 1'b1;        
        cycled_trg_sig <= 1'b0; //self_trg is pulse, width = 1/clk
        cycled_trg_enb_r <= 1'b0;
    end
    else if (cycled_trg_bgn_in & ~cycled_trg_bgn_in_r) begin ///when receive the command, set the cycle_trg_enb_r = 1
    	cycled_trg_enb_r <= 1'b1;
    	cycled_trg_period_cnt <= 25'b0;
        cycled_trg_sig <= 1'b0;
        cycled_trg_end_sig <= 1'b0;
        cycled_trg_cnt <= 16'b0;
		end    	
    else begin  // 
        cycled_trg_period_cnt <= 25'b0;
        cycled_trg_sig <= 1'b0;
        cycled_trg_end_sig <= 1'b0;
        cycled_trg_cnt <= 16'b0;
        cycled_trg_enb_r <= 1'b0;
    end
end


//generate the cycled_trigger_out with about 1000ns width
reg[4:0]	cycled_trg_expd_cnt;
always @(posedge clk_in or negedge rst_in)
begin
	if (!rst_in) begin
		cycled_trg_1us_sig <= 1'b0;
		cycled_trg_expd_cnt <= 5'b0;
	end
	else if (cycled_trg_sig) begin // re-triggerable
		cycled_trg_1us_sig <= 1'b1;
		cycled_trg_expd_cnt <= 5'b0;
	end
	else if (cycled_trg_1us_sig && (cycled_trg_expd_cnt < 6'd50)) begin //less than 1us, 20ns*50 = 1us
		cycled_trg_expd_cnt <= cycled_trg_expd_cnt + 1;
		cycled_trg_1us_sig <= 1'b1;
	end
	else if (cycled_trg_expd_cnt >= 5'b1_1001) begin
		cycled_trg_expd_cnt <= 5'b0;
		cycled_trg_1us_sig <= 1'b0;
	end
end


assign	cycled_trg_out = cycled_trg_sig;
assign  cycled_trg_end_out = cycled_trg_end_sig;
assign  cycled_trg_1us_out = cycled_trg_1us_sig;

endmodule
