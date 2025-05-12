/*----------------------------------------------------------*/
/* 															*/
/*	file name:	TrgOutCtrl.v			           			*/
/* 	date:		2025/03/18									*/
/* 	version:	v1.0										*/
/* 	author:		Wang Shen									*/
/* 	note:	system clock = 50MHz                            */
/* 															*/
/*----------------------------------------------------------*/

module TrgOutCtrl(
    input			clk_in,
    input           rst_in,
    input           coincid_trg_in, //trigger sources
    input           ext_trg_syn_in, //trigger sources
    input           cycled_trg_in,  //trigger sources
    input           trg_enb_in, 
    input   [7:0]   trg_dead_time_in, //dead time for trigger signal 
    input   [15:0]  eff_trg_cnt_in, //equal to trigger id
    output          eff_trg_out,    //width = 1 clock, signal for the other modules
    output          trg_out_N_acd_a, trg_out_N_acd_b, //width = 500ns, 500us trigger signal with 1000us trigger id check signal
    output          trg_out_N_CsI_track_a, trg_out_N_CsI_track_b,
    output          trg_out_N_CsI_cal_a, trg_out_N_CsI_cal_b,
    output          trg_out_N_Si_a, trg_out_N_Si_b,
    output          daq_busy_out    // busy signal for the DAQ system, used for the beam test
);

parameter   TRG_PULSE_WIDTH = 20; 	//20ns*20 = 400ns
parameter   CHK_PULSE_WIDTH = 50; 	// 20ns*50 = 1us

reg eff_trg_sig; //register the output signal


///internal reg
reg                 trg_send_r;// trigger pulse output
reg	                daq_busy_r;
reg         [7:0]   trg_chksig_width_cnt;// trigger signal and TID check signal's width counter
reg         [19:0]  trg_dead_time_cnt;
reg                 coincid_trg_in_r;

//------------>  state machine for generating trigger signal, which will be sent to the output of FPGA
reg[1:0] c_state, n_state;
parameter   IDLE = 0, 
            SEND_TRG = 1, 
            SEND_TRG_CHK = 2, 
            WAIT_DEAD_TIME = 3;

always @(posedge clk_in)
begin
	if (rst_in) 
		c_state <= IDLE;
	else 
		c_state <= n_state;
end
//IDLE: detect the trigger source. If the selected trigger source is valid, start to send the trigger signal
//SEND_TRG:send the trigger singal , the width is equal to 500ns
//SEND_TRG_CHK: send the trigger id check signal ,if the trigger id is equal to 2^12
//WAIT_DEAD_TIME: wait for the [3ms] dead time
always @(c_state or trg_enb_in or cycled_trg_in or ext_trg_syn_in or coincid_trg_in or coincid_trg_in_r or
					trg_chksig_width_cnt or trg_dead_time_cnt or trg_dead_time_in or eff_trg_cnt_in)
begin
	n_state = IDLE;
	case (c_state)
		IDLE: begin////wait for the valid trigger source
			if (trg_enb_in) 
				n_state = ((coincid_trg_in & ~coincid_trg_in_r) || ext_trg_syn_in || cycled_trg_in)?  SEND_TRG : IDLE;//coincid_trg_in || ext_trg_syn_in || cycled_trg_in			
			else
				n_state = IDLE;
		end
		SEND_TRG: begin//////send the trigger signal
			if (trg_chksig_width_cnt >= (TRG_PULSE_WIDTH-1'b1) )begin
				if (eff_trg_cnt_in[11:0] == 12'b0000_0000_0001)// send the check pulse every 2^12 trigger //12'b0000_0000_0000
					n_state = SEND_TRG_CHK;
				else
					n_state = WAIT_DEAD_TIME;
			end
			else
				n_state = SEND_TRG;
		end
		SEND_TRG_CHK: begin //send the trigger id check signal
			if (trg_chksig_width_cnt >= (5'd9 + CHK_PULSE_WIDTH))
				n_state = WAIT_DEAD_TIME;
			else 		
				n_state = SEND_TRG_CHK;		
		end		
        WAIT_DEAD_TIME: begin////wait for the dead time
            if ( trg_dead_time_cnt > {trg_dead_time_in, 12'b0000_0000_0000} )  //the time step is about 82us  {trg_dead_time, 16'b0101_0000_0000_0000} ) begin //
                n_state = IDLE;//IDLE;
            else 
                n_state = WAIT_DEAD_TIME;
        end
        default: begin
            n_state = IDLE;
        end
    endcase
end

always @(posedge clk_in)
    if(rst_in)
        coincid_trg_in_r <= 1'b0;
    else
        coincid_trg_in_r <= coincid_trg_in;
   
always @(posedge clk_in)
begin
    if (rst_in) begin
        trg_send_r <= 1'b0;
        eff_trg_sig <= 1'b0;
        daq_busy_r <= 1'b0;
        trg_chksig_width_cnt <= 8'b0;
        trg_dead_time_cnt <= 20'b0;
    end
    else begin
     case (c_state)
        IDLE: begin
            trg_chksig_width_cnt <= 8'b0;
            trg_dead_time_cnt <= 20'b0;
            if (trg_enb_in) begin  //
                trg_send_r <= ((coincid_trg_in & ~coincid_trg_in_r) || ext_trg_syn_in || cycled_trg_in);//coincid_trg_in || ext_trg_syn_in || cycled_trg_in
                eff_trg_sig <= ((coincid_trg_in & ~coincid_trg_in_r) || ext_trg_syn_in || cycled_trg_in);//coincid_trg_in || ext_trg_syn_in || cycled_trg_in
                daq_busy_r <= ((coincid_trg_in & ~coincid_trg_in_r) || ext_trg_syn_in || cycled_trg_in);//coincid_trg_in || ext_trg_syn_in || cycled_trg_in           
            end
            else begin
                trg_send_r <= 1'b0;
                eff_trg_sig <= 1'b0;
                daq_busy_r <= 1'b0;            
            end
        end
        SEND_TRG: begin///send the trigger signal
            eff_trg_sig <= 1'b0;//just one clock width
            daq_busy_r <= 1'b1;// it is busy     
            if (trg_chksig_width_cnt >= (TRG_PULSE_WIDTH-1'b1)) begin//the width of trigger is 400ns
                trg_send_r <= 1'b0;
                trg_chksig_width_cnt <= 8'b0;
                trg_dead_time_cnt <= 20'b0;
            end
            else begin
                trg_chksig_width_cnt <= trg_chksig_width_cnt + 1;
                trg_send_r <= 1'b1;
            end        
        end
        SEND_TRG_CHK: begin //send the check signal
            eff_trg_sig <= 1'b0; 
            trg_chksig_width_cnt <= trg_chksig_width_cnt + 1;
            trg_dead_time_cnt <= trg_dead_time_cnt + 1;
            if (trg_chksig_width_cnt >= (5'd9 + CHK_PULSE_WIDTH))//0.5us+1us
                trg_send_r <= 1'b0; 
            else if (trg_chksig_width_cnt >= 5'd9)//0.5us gap between the trigger signal and the trigger id check signal
                trg_send_r <= 1'b1;	// trigger id check signal
        end		
        WAIT_DEAD_TIME: begin
            eff_trg_sig <= 1'b0; 
            trg_send_r <= 1'b0;
            if ( trg_dead_time_cnt > {trg_dead_time_in, 12'b0000_0000_0000} ) begin  //{trg_dead_time, 16'b0101_0000_0000_0000} ) begin //
                trg_dead_time_cnt <= 20'b0;
                daq_busy_r <= 1'b0;  
            end
            else begin 
                trg_dead_time_cnt <= trg_dead_time_cnt + 1;
            end
        end
        default: begin
            trg_send_r <= 1'b0;
            eff_trg_sig <= 1'b0;
            daq_busy_r <= 1'b0;
            trg_chksig_width_cnt <= 8'b0;
            trg_dead_time_cnt <= 20'b0;
        end
     endcase
    end
end

assign  eff_trg_out = eff_trg_sig;
assign  trg_out_N_acd_a = ~trg_send_r;
assign  trg_out_N_acd_b = ~trg_send_r;
assign  trg_out_N_CsI_track_a = ~trg_send_r;
assign  trg_out_N_CsI_track_b = ~trg_send_r;
assign  trg_out_N_CsI_cal_a = ~trg_send_r;
assign  trg_out_N_CsI_cal_b = ~trg_send_r;
assign  trg_out_N_Si_a = ~trg_send_r;
assign  trg_out_N_Si_b = ~trg_send_r;
assign	daq_busy_out = daq_busy_r;

endmodule