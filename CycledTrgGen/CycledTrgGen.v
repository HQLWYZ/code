/*----------------------------------------------------------*/
/* 															*/
/*	file name:	CycledTrgGen.v			           			*/
/* 	date:		2025/03/07									*/
/* 	modified:	2026/01/02								 	*/
/* 	version:	v1.0										*/
/* 	author:		Wang Shen									*/
/* 	email:		wangshen@pmo.ac.cn							*/
/* 	note:		                                            */
/* 	note1:		system clock = 50MHz						*/
/* 															*/
/*----------------------------------------------------------*/

module CycledTrgGen(
	input			clk_in,
	input			rst_in,
    input           cycled_trg_bgn_in,
    input   [7:0]	cycled_trg_period_in,//the Unit = 2ms. So the maximum period is 2ms*2^8 = 512ms. Default: 10ms[baseline mode], 20ms[normal cali mode], 50ms[waveform cali mode]
    input   [15:0]	cycled_trg_num_in,//cycled trigger number
    output          cycled_trg_out,
    output          cycled_trg_end_out//width = 1 clock
	);
	
parameter   TRG_PERIOD_UNIT_2MS = 100000; //100000*20ns = 2ms

//register the output signal
reg  cycled_trg_end_sig;

//cycled trigger 
reg  cycled_trg_sig;
reg[27:0]   cycled_trg_period_cnt;//the clk is 50Mhz
reg[15:0]   cycled_trg_cnt;


reg cycled_trg_bgn_in_r;
always@(posedge clk_in)
    if(rst_in)
        cycled_trg_bgn_in_r <= 1'b0;
    else
        cycled_trg_bgn_in_r <= cycled_trg_bgn_in; 

reg[2:0] c_state, n_state;

parameter   IDLE = 0, 
            CYCLED_TRG_CHECK = 1, 
            CYCLED_TRG_GEN = 2, 
			CYCLED_TRG_END = 3;

always @(posedge clk_in)
begin
	if (rst_in)
		c_state <= IDLE;
	else 
		c_state <= n_state;	
end

always @(c_state or cycled_trg_bgn_in or cycled_trg_cnt or cycled_trg_period_cnt or cycled_trg_num_in)
begin
	n_state = IDLE; //default value
	case(c_state)
		IDLE: begin
			if (cycled_trg_bgn_in & ~cycled_trg_bgn_in_r)   ///detect the START OF cycled_trg_bgn_in signal 
				n_state = CYCLED_TRG_CHECK;
			else 
				n_state = IDLE;			
		end

		CYCLED_TRG_CHECK: begin
			if (cycled_trg_cnt >= cycled_trg_num_in)   // 
				n_state = CYCLED_TRG_END;
			else 
				n_state = CYCLED_TRG_GEN;			
		end

		CYCLED_TRG_GEN: begin
			if (cycled_trg_period_cnt == {cycled_trg_period_in * TRG_PERIOD_UNIT_2MS}) //
            //if (cycled_trg_period_cnt == {cycled_trg_period_in, 2'b0})//[ONLY FOR SIMULATION]
				n_state = CYCLED_TRG_CHECK;
			else 
				n_state = CYCLED_TRG_GEN;			
		end

		CYCLED_TRG_END: begin
				n_state = IDLE;			
		end

		default: begin
			n_state = IDLE;			
		end
	endcase	
end

always @(posedge clk_in)
begin
	   if (rst_in) begin
        cycled_trg_period_cnt <= 28'b0;
        cycled_trg_sig <= 1'b0;
        cycled_trg_end_sig <= 1'b0;
        cycled_trg_cnt <= 16'b0;
    end
    else begin
        case(c_state) 
         IDLE: begin
            cycled_trg_period_cnt <= 28'b0;
            cycled_trg_sig <= 1'b0;
            cycled_trg_end_sig <= 1'b0;
            cycled_trg_cnt <= 16'b0;
         end
        CYCLED_TRG_CHECK: begin
            cycled_trg_cnt <= cycled_trg_cnt+1'b1;
        end

        CYCLED_TRG_GEN: begin
            cycled_trg_period_cnt <= cycled_trg_period_cnt + 1'b1;
            //if( (cycled_trg_period_cnt == {cycled_trg_period_in, 2'b0}) ) begin //[ONLY FOR SIMULATION]
            if( (cycled_trg_period_cnt == {cycled_trg_period_in * TRG_PERIOD_UNIT_2MS}) ) begin 
                cycled_trg_sig <= 1'b1;//
                cycled_trg_period_cnt <= 28'b0;
            end
            else begin
                cycled_trg_sig <= 1'b0;
            end
         end

        CYCLED_TRG_END: begin
            cycled_trg_end_sig <= 1'b1;        
            cycled_trg_sig <= 1'b0; //self_trg is pulse, width = 1/clk
        end

         default: begin
            cycled_trg_period_cnt <= 28'b0;
            cycled_trg_sig <= 1'b0;
            cycled_trg_end_sig <= 1'b0;
            cycled_trg_cnt <= 16'b0;
         end
        endcase
    end
end

assign	cycled_trg_out = cycled_trg_sig;
assign  cycled_trg_end_out = cycled_trg_end_sig;

endmodule
